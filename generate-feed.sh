#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${1:-$PROJECT_ROOT/_site}"
OUTPUT="$OUTPUT_DIR/feed.xml"
BLOG_DIR="$PROJECT_ROOT/src/blog"
SITE_URL="https://samcollier.dev"

mkdir -p "$(dirname "$OUTPUT")"

cat > "$OUTPUT" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>Sam Collier</title>
    <link>https://samcollier.dev</link>
    <description>Personal blog about game development and low-level systems programming</description>
    <language>en</language>
    <atom:link href="https://samcollier.dev/feed.xml" rel="self" type="application/rss+xml"/>
EOF

items_dir=$(mktemp -d)
trap 'rm -rf "$items_dir"' EXIT

find "$BLOG_DIR" -name '*.typ' ! -name 'blog.typ' | sort | while IFS= read -r file; do
  title=$(grep -oP 'page-title:\s*"\K[^"]+' "$file" || true)
  desc=$(grep -oP 'description:\s*"\K[^"]+' "$file" || true)
  year=$(grep -oP 'year:\s*\K\d+' "$file" || true)
  month=$(grep -oP 'month:\s*\K\d+' "$file" || true)
  day=$(grep -oP 'day:\s*\K\d+' "$file" || true)

  year="${year#0}"
  month="${month#0}"
  day="${day#0}"

  relpath="${file#$BLOG_DIR/}"
  slug="${relpath%.typ}"
  link="$SITE_URL/blog/$slug/"

  if [ -z "$year" ]; then continue; fi

  pubdate=$(date -d "$year-$month-$day" -R 2>/dev/null || true)

  title=$(echo "$title" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')
  desc=$(echo "$desc" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')

  html_file="$OUTPUT_DIR/blog/$slug/index.html"
  content=""
  if [ -f "$html_file" ]; then
    content=$(sed -n '/<main>/,/<\/main>/p' "$html_file" | sed '1s/.*<main>//; $s/<\/main>.*//')
  fi

  sort_key="$(printf '%04d' "$year")-$(printf '%02d' "$month")-$(printf '%02d' "$day")"
  safe_slug="${slug//\//-}"

  cat > "$items_dir/$sort_key.$safe_slug" << ITEM
    <item>
      <title>$title</title>
      <link>$link</link>
      <guid isPermaLink="true">$link</guid>
      <description>$desc</description>
      <pubDate>$pubdate</pubDate>
      <content:encoded><![CDATA[$content]]></content:encoded>
    </item>
ITEM
done

for f in $(ls -r "$items_dir" 2>/dev/null); do
  cat "$items_dir/$f" >> "$OUTPUT"
done

echo '  </channel>
</rss>' >> "$OUTPUT"
