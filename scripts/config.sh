#!/bin/sh

CONFIG_FILE=$1

alias echo="echo CONFIG:"

if [ -f "${CONFIG_FILE}" ]; then
  echo "[${CONFIG_FILE}] already exists. Exiting..."
  exit 0
else
  echo "[${CONFIG_FILE}] doesn't exist. Initializing..."
  printf "# Generated config: START ----------\n" > "${CONFIG_FILE}"
fi

### Setting up node:
printf '\n[Eth]\n' >> "${CONFIG_FILE}"

### Switch to network:
if [ -n "${NETWORK+1}" ]; then
  echo "Configuring network..."
  case "${NETWORK}" in
    mainnet)
      echo "Network is mainnet (id=1)"
      printf 'NetworkId = 1\n' >> "${CONFIG_FILE}"
      ;;
    ropsten)
      echo "Network is ropsten (id=3)"
      printf 'NetworkId = 3\n' >> "${CONFIG_FILE}"
      ;;
    rinkeby)
      echo "Network is rinkeby (id=4)"
      printf 'NetworkId = 4\n' >> "${CONFIG_FILE}"
      ;;
    goerli)
      echo "Network is goerli (id=5)"
      printf 'NetworkId = 5\n' >> "${CONFIG_FILE}"
      ;;
    kovan)
      echo "Network is kovan (id=42)"
      printf 'NetworkId = 42\n' >> "${CONFIG_FILE}"
      ;;
    sepolia)
      echo "Network is sepolia (id=11155111)"
      printf 'NetworkId = 11155111\n' >> "${CONFIG_FILE}"
      ;;
    *)
      echo "Unknown network selected: ${NETWORK}... Defaulting to ropsten (id=3)"
      printf 'NetworkId = 3\n' >> "${CONFIG_FILE}"
      ;;
  esac
else
  echo "Using mainnet by default (id=1)"
  printf 'NetworkId = 1\n' >> "${CONFIG_FILE}"
fi

if [ -n "${SYNCMODE+1}" ]; then
  echo "Setting syncmode ${SYNCMODE}"
  printf 'SyncMode = "%s"\n' "${SYNCMODE}" >> "${CONFIG_FILE}"
fi

if [ -n "${DB_CACHE+1}" ]; then
  echo "Setting cache ${DB_CACHE}"
  printf 'DatabaseCache = %s\n' "${DB_CACHE}" >> "${CONFIG_FILE}"
fi

if printf "${NOPRUNING_ENABLE}" | grep -q "[Yy1]"; then
  echo "Enabling nopruning..."
  printf 'NoPruning = true\n' >> "${CONFIG_FILE}"
fi

### Setting up RPC server:
if printf "${RPC_ENABLE}" | grep -q "[Yy1]"; then
  ### This transforms string 'a, b,c, d' into TOML-compatible '"a","b","c","d"'
  ### TODO: need to rewrite this with regex
  if [ -n "${RPC_MODULES+1}" ]; then
    for i in $(printf "${RPC_MODULES}" | tr ',' ' '); do
      if [ -n "${result+1}" ]; then
        result="$result, \"$i\""
      else
        result="\"$i\""
      fi
    done
    RPC_MODULES=$result
    unset result
  else
    RPC_MODULES='"net","web3","eth"'
  fi

  ### This transforms string 'a, b,c, d' into TOML-compatible '"a","b","c","d"'
  ### TODO: need to rewrite this with regex
  if [ -n "${RPC_WS_MODULES+1}" ]; then
    for i in $(printf "${RPC_WS_MODULES}" | tr ',' ' '); do
      if [ -n "${result+1}" ]; then
        result="$result, \"$i\""
      else
        result="\"$i\""
      fi
    done
    RPC_WS_MODULES=$result
    unset result
  else
    RPC_WS_MODULES='"net","web3","eth"'
  fi

	printf '\n[Node]\n' >> "${CONFIG_FILE}"
	printf 'HTTPHost = "%s"\n' ${RPC_HOST:-0.0.0.0} >> "${CONFIG_FILE}"
	printf 'WSHost = "%s"\n' ${RPC_WS_HOST:-0.0.0.0} >> "${CONFIG_FILE}"
  printf 'HTTPModules = [%s]\n' "${RPC_MODULES}" >> "${CONFIG_FILE}"
  printf 'WSModules = [%s]\n' "${RPC_WS_MODULES}" >> "${CONFIG_FILE}"
  if printf "${RPC_ALLOW_UNPROTECTEDTX}" | grep -q "[Yy1]"; then
    echo "Enabling RPC_ALLOW_UNPROTECTEDTX"
    printf 'AllowUnprotectedTxs = true\n'  >> "${CONFIG_FILE}"
  fi
fi

printf '\n[Node.P2P]\n' >> "${CONFIG_FILE}"

if [ -n "${P2P_MAX_PEERS+1}" ]; then
  echo "Setting P2P max peers ${P2P_MAX_PEERS}"
  printf 'MaxPeers = %s\n' "${P2P_MAX_PEERS}" >> "${CONFIG_FILE}"
fi

if printf "${P2P_DISCOVERY_ENABLE}" | grep -q "[Yy1]"; then
  echo "Enabling nopruning"
  printf 'NoPruning = true\n' >> "${CONFIG_FILE}"
fi

if [ -n "${P2P_DISCOVERY_DISABLE+1}" ]; then
  echo "Enabling P2P discovery ${P2P_DISCOVERY_DISABLE}"
  printf 'NoDiscovery = false\n'  >> "${CONFIG_FILE}"
fi

echo "Config initialization completed successfully (${CONFIG_FILE})"
printf "\n# Generated config: END ----------\n" >> "${CONFIG_FILE}"
