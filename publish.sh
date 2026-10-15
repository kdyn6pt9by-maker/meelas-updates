#!/bin/zsh
# نشر تحديث للبرامج الثلاثة: يبني نسخ الإصدار، يرفعها على GitHub، ويحدّث version.json.
# الاستخدام:  ./publish.sh  (ارفع versionCode في المشروع اللي تبي تحدّثه قبلها)
set -e
ROOT="${0:A:h:h}"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
GH=~/.local/bin/gh
AAPT=$(ls -d ~/Library/Android/sdk/build-tools/*/ | tail -1)aapt2
REPO=kdyn6pt9by-maker/meelas-updates
TAG="v$(date +%Y%m%d-%H%M)"
OUT="$ROOT/Updates/out"; rm -rf "$OUT"; mkdir -p "$OUT"
typeset -A NAMES; NAMES=(Launcher meelas Check-Android check BuSita-Android busita)
typeset -A TITLES; TITLES=(Launcher "ميلس العوي" Check-Android "Check" BuSita-Android "بوسته")
apps=()
for P in Launcher Check-Android BuSita-Android; do
  (cd "$ROOT/$P" && ./gradlew -q assembleRelease)
  F="$OUT/${NAMES[$P]}.apk"; cp "$ROOT/$P/app/build/outputs/apk/release/app-release.apk" "$F"
  B=$("$AAPT" dump badging "$F" | head -1)
  PKG=$(echo "$B" | sed -E "s/.*name='([^']+)'.*/\1/")
  VC=$(echo "$B" | sed -E "s/.*versionCode='([^']+)'.*/\1/")
  VN=$(echo "$B" | sed -E "s/.*versionName='([^']+)'.*/\1/")
  SHA=$(shasum -a 256 "$F" | cut -d' ' -f1)
  apps+=("{\"package\":\"$PKG\",\"name\":\"${TITLES[$P]}\",\"versionCode\":$VC,\"versionName\":\"$VN\",\"url\":\"https://github.com/$REPO/releases/download/$TAG/${NAMES[$P]}.apk\",\"sha256\":\"$SHA\"}")
  echo "✓ ${TITLES[$P]}  $VN ($VC)"
done
$GH release create "$TAG" "$OUT"/*.apk --repo "$REPO" --title "$TAG" --notes "تحديث برامج ميلس العوي" >/dev/null
echo "{\"apps\":[${(j:,:)apps}]}" > "$ROOT/Updates/version.json"
cd "$ROOT/Updates"
git add version.json
git -c user.name="Meelas" -c user.email="noreply@users.noreply.github.com" commit -qm "Publish $TAG

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push -q
echo "✓ تم النشر: $TAG — اضغط «تحديث البرامج» في ميلس العوي"
