const _named = {
  'amp': '&',
  'quot': '"',
  'apos': "'",
  'lt': '<',
  'gt': '>',
  'nbsp': ' ',
  'ndash': '–',
  'mdash': '—',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
  'hellip': '…',
  'trade': '™',
  'reg': '®',
  'copy': '©',
};

final _entity = RegExp(r'&(#[xX][0-9a-fA-F]+|#\d+|[a-zA-Z]+);');

/// [text] with its HTML entities turned into the characters they stand for:
/// the common named ones (`&amp;`, `&quot;`, `&rsquo;`…) and numeric ones
/// (`&#39;`, `&#x27;`). Anything else is left as it is.
///
/// Steam sends its game descriptions with the entities still in them.
String decodeHtmlEntities(String text) {
  return text.replaceAllMapped(_entity, (match) {
    final body = match[1]!;
    if (!body.startsWith('#')) return _named[body] ?? match[0]!;

    final isHex = body[1] == 'x' || body[1] == 'X';
    final code = int.tryParse(
      body.substring(isHex ? 2 : 1),
      radix: isHex ? 16 : 10,
    );
    final valid =
        code != null &&
        code > 0 &&
        code <= 0x10FFFF &&
        !(code >= 0xD800 && code <= 0xDFFF);
    return valid ? String.fromCharCode(code) : match[0]!;
  });
}
