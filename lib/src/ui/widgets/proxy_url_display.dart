/// Display form of a proxy URL with any `user:password@` credentials masked
/// (ISS-021). Never use the result to connect.
String maskProxyUrlForDisplay(String url) =>
    url.replaceFirst(RegExp(r'(?<=//)[^/@\s]+@'), '•••@');
