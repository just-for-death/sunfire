/// IMP-052: desktop identity. The Linux application id is the one already in
/// use (linux/CMakeLists.txt APPLICATION_ID → GTK application-id / prgname and
/// the `~/.local/share/<id>` data dir). It is kept as-is: changing it would
/// orphan existing users' extensions and covers. Android/iOS use
/// `com.sunfire.app`; test/app_identity_test.dart keeps every reference in sync.
const String kLinuxApplicationId = 'com.sunfire.sunfire';
