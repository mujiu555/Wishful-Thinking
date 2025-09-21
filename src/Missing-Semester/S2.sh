#!/bin/env -vS zsh

# 1
ls -al
ls -alh
ls -t
ls --color=auto

# 2
macro ()
{
  echo $(pwd) > /tmp/macro-path
}

polo ()
{
  cd $(cat /tmp/macro-path)
}

# 3
log () {
  count=1
  result=0
  while [[ $result -eq 0 ]]; do
    ./S2-bash.sh 2>&1 >> /tmp/log
    result=$?
    let count++
  done
  cat /tmp/log
  echo $count
}

# 4
fin () {
  find -name '*.html' | xargs -0 -- zip n.zip
}
