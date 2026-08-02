#!/bin/bash
cd /home/jes/tarot
mkdir -p images/sources

declare -A URLS
URLS[c-01]="https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Cups01.jpg/960px-Cups01.jpg"
URLS[c-02]="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Cups02.jpg/960px-Cups02.jpg"
URLS[c-03]="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cups03.jpg/960px-Cups03.jpg"
URLS[c-04]="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Cups04.jpg/960px-Cups04.jpg"
URLS[c-05]="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Cups05.jpg/960px-Cups05.jpg"
URLS[c-06]="https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Cups06.jpg/960px-Cups06.jpg"
URLS[c-07]="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Cups07.jpg/960px-Cups07.jpg"
URLS[c-08]="https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Cups08.jpg/960px-Cups08.jpg"
URLS[c-09]="https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Cups09.jpg/960px-Cups09.jpg"
URLS[c-10]="https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Cups10.jpg/960px-Cups10.jpg"
URLS[c-11]="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Cups11.jpg/960px-Cups11.jpg"
URLS[c-12]="https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Cups12.jpg/960px-Cups12.jpg"
URLS[c-13]="https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Cups13.jpg/960px-Cups13.jpg"
URLS[c-14]="https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Cups14.jpg/960px-Cups14.jpg"
URLS[p-01]="https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Pents01.jpg/960px-Pents01.jpg"
URLS[p-02]="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Pents02.jpg/960px-Pents02.jpg"
URLS[p-03]="https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Pents03.jpg/960px-Pents03.jpg"
URLS[p-04]="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Pents04.jpg/960px-Pents04.jpg"
URLS[p-05]="https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Pents05.jpg/960px-Pents05.jpg"
URLS[p-06]="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Pents06.jpg/960px-Pents06.jpg"
URLS[p-07]="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Pents07.jpg/960px-Pents07.jpg"
URLS[p-08]="https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Pents08.jpg/960px-Pents08.jpg"
URLS[p-09]="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Pents09.jpg/960px-Pents09.jpg"
URLS[p-10]="https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Pents10.jpg/960px-Pents10.jpg"
URLS[p-11]="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Pents11.jpg/960px-Pents11.jpg"
URLS[p-12]="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Pents12.jpg/960px-Pents12.jpg"
URLS[p-13]="https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Pents13.jpg/960px-Pents13.jpg"
URLS[p-14]="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Pents14.jpg/960px-Pents14.jpg"
URLS[s-01]="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Swords01.jpg/960px-Swords01.jpg"
URLS[s-02]="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Swords02.jpg/960px-Swords02.jpg"
URLS[s-03]="https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Swords03.jpg/960px-Swords03.jpg"
URLS[s-04]="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Swords04.jpg/960px-Swords04.jpg"
URLS[s-05]="https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Swords05.jpg/960px-Swords05.jpg"
URLS[s-06]="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Swords06.jpg/960px-Swords06.jpg"
URLS[s-07]="https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Swords07.jpg/960px-Swords07.jpg"
URLS[s-08]="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Swords08.jpg/960px-Swords08.jpg"
URLS[s-09]="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Swords09.jpg/960px-Swords09.jpg"
URLS[s-10]="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Swords10.jpg/960px-Swords10.jpg"
URLS[s-11]="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Swords11.jpg/960px-Swords11.jpg"
URLS[s-12]="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Swords12.jpg/960px-Swords12.jpg"
URLS[s-13]="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Swords13.jpg/960px-Swords13.jpg"
URLS[s-14]="https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Swords14.jpg/960px-Swords14.jpg"
URLS[w-01]="https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Wands01.jpg/960px-Wands01.jpg"
URLS[w-02]="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Wands02.jpg/960px-Wands02.jpg"
URLS[w-03]="https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Wands03.jpg/960px-Wands03.jpg"
URLS[w-04]="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Wands04.jpg/960px-Wands04.jpg"
URLS[w-05]="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Wands05.jpg/960px-Wands05.jpg"
URLS[w-06]="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Wands06.jpg/960px-Wands06.jpg"
URLS[w-07]="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Wands07.jpg/960px-Wands07.jpg"
URLS[w-08]="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Wands08.jpg/960px-Wands08.jpg"
URLS[w-09]="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Tarot_Nine_of_Wands.jpg/960px-Tarot_Nine_of_Wands.jpg"
URLS[w-10]="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Wands10.jpg/960px-Wands10.jpg"
URLS[w-11]="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Wands11.jpg/960px-Wands11.jpg"
URLS[w-12]="https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Wands12.jpg/960px-Wands12.jpg"
URLS[w-13]="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Wands13.jpg/960px-Wands13.jpg"
URLS[w-14]="https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Wands14.jpg/960px-Wands14.jpg"

ok=0
fail=0
for prefix in $(echo "${!URLS[@]}" | tr ' ' '\n' | sort); do
    dest="images/sources/${prefix}.jpg"
    if [ -f "$dest" ]; then
        echo "CACHED: $prefix"
        ok=$((ok+1))
        continue
    fi
    url="${URLS[$prefix]}"
    if wget -q --user-agent="Mozilla/5.0 (tarot-tracer)" "$url" -O "$dest" 2>/dev/null; then
        echo "OK: $prefix"
        ok=$((ok+1))
    else
        echo "FAIL: $prefix"
        rm -f "$dest"
        fail=$((fail+1))
        sleep 10
    fi
    sleep 3
done
echo "Done: $ok OK, $fail failed"
