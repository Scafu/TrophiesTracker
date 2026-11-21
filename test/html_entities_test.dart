import 'package:flutter_test/flutter_test.dart';
import 'package:trophies_tracker/core/utils/html_entities.dart';

void main() {
  test('named entities become their characters', () {
    expect(
      decodeHtmlEntities('The &quot;Initiative&quot; &amp; Baldur&rsquo;s'),
      'The "Initiative" & Baldur’s',
    );
    expect(decodeHtmlEntities('a&nbsp;b &lt;i&gt;'), 'a b <i>');
  });

  test('numeric entities, decimal and hex, become their characters', () {
    expect(
      decodeHtmlEntities('it&#39;s &#x27;ok&#X27; &#8217;'),
      "it's 'ok' ’",
    );
  });

  test('a double-encoded entity is decoded once', () {
    expect(decodeHtmlEntities('&amp;quot;'), '&quot;');
  });

  test('what is not a known entity is left alone', () {
    expect(
      decodeHtmlEntities('Tom & Jerry &unknown; &#0; &#xD800; &#99999999;'),
      'Tom & Jerry &unknown; &#0; &#xD800; &#99999999;',
    );
    expect(decodeHtmlEntities('plain text'), 'plain text');
    expect(decodeHtmlEntities(''), '');
  });
}
