// lib/src/core/services/tag_service.dart
//
// L10.2: TagService - manages user-defined custom tags for manga.
//
// Features:
// - CRUD operations for tags
// - Assign/remove tags to/from manga
// - Query manga by tag
// - Persistent color coding
//
// Manga identity: all manga* parameters are [Manga.canonicalKey] / serverId
// (positive for Suwayomi, negative for local-only). Never pass Isar auto-ids.

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar_community/isar.dart';

import '../db/isar_service.dart';
import '../db/models/manga.dart';
import '../db/models/tag.dart';

/// TagService - manages user-defined custom tags for manga.
class TagService {
  TagService._();
  static final TagService instance = TagService._();

  /// Normalize a user-entered tag name. Returns null when empty after trim.
  static String? normalizeTagName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  /// Accepts `#RRGGBB` (case-insensitive). Empty/invalid → false.
  static bool isValidTagColor(String color) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color.trim());
  }

  /// Get all tags, sorted by name.
  Future<List<Tag>> getAllTags() async {
    if (!IsarService.instance.isInitialized) return [];
    return await IsarService.instance.isar.tags.where().sortByName().findAll();
  }

  /// Get a tag by Isar id.
  Future<Tag?> getTag(int id) async {
    if (!IsarService.instance.isInitialized) return null;
    return await IsarService.instance.isar.tags.get(id);
  }

  /// Get a tag by name (case-insensitive).
  Future<Tag?> getTagByName(String name) async {
    if (!IsarService.instance.isInitialized) return null;
    return await IsarService.instance.isar.tags
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  /// Create a new tag.
  Future<Tag?> createTag({
    required String name,
    String color = '#FF5722',
  }) async {
    if (!IsarService.instance.isInitialized) return null;
    final trimmed = normalizeTagName(name);
    if (trimmed == null) return null;
    final resolvedColor =
        isValidTagColor(color) ? color.trim() : '#FF5722';

    final existing = await getTagByName(trimmed);
    if (existing != null) return existing;

    final tag = Tag()
      ..name = trimmed
      ..color = resolvedColor
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..isUserCreated = true;

    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.isar.tags.put(tag);
    });
    return tag;
  }

  /// Update a tag's name or color.
  Future<bool> updateTag(Tag tag, {String? name, String? color}) async {
    if (!IsarService.instance.isInitialized) return false;
    try {
      if (name != null) {
        final trimmed = normalizeTagName(name);
        if (trimmed == null) return false;
        final existing = await getTagByName(trimmed);
        if (existing != null && existing.id != tag.id) return false;
        tag.name = trimmed;
      }
      if (color != null) {
        if (!isValidTagColor(color)) return false;
        tag.color = color.trim();
      }
      await IsarService.instance.isar.writeTxn(() async {
        await IsarService.instance.isar.tags.put(tag);
      });
      return true;
    } catch (e) {
      debugPrint('[TagService] updateTag failed: $e');
      return false;
    }
  }

  /// Delete a tag and remove it from all manga.
  Future<void> deleteTag(int tagId) async {
    if (!IsarService.instance.isInitialized) return;
    await IsarService.instance.isar.writeTxn(() async {
      final mangas = await IsarService.instance.isar.mangas
          .filter()
          .tagIdsElementEqualTo(tagId)
          .findAll();
      for (final manga in mangas) {
        manga.tagIds.remove(tagId);
        await IsarService.instance.isar.mangas.put(manga);
      }
      await IsarService.instance.isar.tags.delete(tagId);
    });
  }

  /// Assign a tag to a manga.
  ///
  /// [mangaServerId] is [Manga.canonicalKey] (serverId), not the Isar auto-id.
  Future<bool> assignTag(int mangaServerId, int tagId) async {
    if (!IsarService.instance.isInitialized) return false;
    if (mangaServerId == 0) return false;
    try {
      final manga =
          await IsarService.instance.getMangaByServerId(mangaServerId);
      if (manga == null) return false;
      final tag = await IsarService.instance.isar.tags.get(tagId);
      if (tag == null) return false;
      if (manga.tagIds.contains(tagId)) return true;

      await IsarService.instance.isar.writeTxn(() async {
        manga.tagIds.add(tagId);
        await IsarService.instance.isar.mangas.put(manga);
      });
      return true;
    } catch (e) {
      debugPrint('[TagService] assignTag failed: $e');
      return false;
    }
  }

  /// Remove a tag from a manga.
  ///
  /// [mangaServerId] is [Manga.canonicalKey] (serverId), not the Isar auto-id.
  Future<bool> removeTag(int mangaServerId, int tagId) async {
    if (!IsarService.instance.isInitialized) return false;
    if (mangaServerId == 0) return false;
    try {
      final manga =
          await IsarService.instance.getMangaByServerId(mangaServerId);
      if (manga == null) return false;
      if (!manga.tagIds.contains(tagId)) return true;

      await IsarService.instance.isar.writeTxn(() async {
        manga.tagIds.remove(tagId);
        await IsarService.instance.isar.mangas.put(manga);
      });
      return true;
    } catch (e) {
      debugPrint('[TagService] removeTag failed: $e');
      return false;
    }
  }

  /// Get all manga canonical keys with a specific tag.
  Future<List<int>> getMangaIdsByTag(int tagId) async {
    if (!IsarService.instance.isInitialized) return [];
    final mangas = await IsarService.instance.isar.mangas
        .filter()
        .tagIdsElementEqualTo(tagId)
        .findAll();
    return mangas.map((Manga m) => m.canonicalKey).toList();
  }

  /// Get all tags for a manga ([mangaServerId] = [Manga.canonicalKey]).
  Future<List<Tag>> getTagsForManga(int mangaServerId) async {
    if (!IsarService.instance.isInitialized) return [];
    if (mangaServerId == 0) return [];
    final manga =
        await IsarService.instance.getMangaByServerId(mangaServerId);
    if (manga == null) return [];
    final tags = <Tag>[];
    for (final id in manga.tagIds) {
      final tag = await IsarService.instance.isar.tags.get(id);
      if (tag != null) tags.add(tag);
    }
    return tags;
  }

  /// Search tags by name prefix.
  Future<List<Tag>> searchTags(String query) async {
    if (!IsarService.instance.isInitialized) return [];
    if (query.trim().isEmpty) return getAllTags();
    return await IsarService.instance.isar.tags
        .filter()
        .nameStartsWith(query, caseSensitive: false)
        .findAll();
  }

  /// Get or create a tag by name (for migration/import).
  Future<Tag> getOrCreateTag(String name, {String? color}) async {
    final existing = await getTagByName(name);
    if (existing != null) return existing;
    final created = await createTag(name: name, color: color ?? '#FF5722');
    return created ??
        (Tag()
          ..name = name
          ..color = color ?? '#FF5722');
  }
}
