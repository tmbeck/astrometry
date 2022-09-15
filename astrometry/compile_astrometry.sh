#! /bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ $(uname -m) == arm* ]]; then
  echo "-------------------------------------------------------------"
  echo "ARM processor detected >> using ARM (raspberry pi) install scripts.";
  echo "-------------------------------------------------------------"
  $SCRIPT_DIR/arm/rpi_compile.sh
else
  echo "-------------------------------------------------------------"
  echo "Non-arm processor detected >> using x86_64 (Ubuntu) install scripts."
  echo "-------------------------------------------------------------"
  $SCRIPT_DIR/intel/intel_compile.sh
fi
