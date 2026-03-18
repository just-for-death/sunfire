enum AppUrls {
  catalystGithubUrl(url: "https://github.com/just-for-death/catalyst"),
  catalystLatestReleaseUrl(
      url: "https://github.com/just-for-death/catalyst/releases/latest"),
  serverHelp(url: "https://github.com/Suwayomi/Suwayomi-Server/wiki"),
  catalystWhatsNew(
      url: "https://github.com/just-for-death/catalyst/releases/tag/"),
  catalystLatestReleaseApiUrl(
    url: "https://api.github.com/repos/just-for-death/catalyst/releases/latest",
  ),
  flareSolverr(
      url: "https://github.com/FlareSolverr/FlareSolverr?tab=readme-ov-file#installation");

  const AppUrls({required this.url});

  final String url;
}
