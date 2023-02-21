# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

deploy-arbitrum:
	forge script script/DeployMainnet.s.sol:DeployMainnetScript --rpc-url $(ARBITRUM_ONE_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --verifier-url $(ARBISCAN)

deploy-arbitrum-goerli:
	forge script script/DeployDev.s.sol:DeployDevScript --rpc-url $(ARBITRUM_TESTNET) --private-key $(PRIVATE_KEY_TESTNET) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --verifier-url $(ARBISCAN_GOERLI)

dev-mainnet:
	forge script script/DeployMainnet.s.sol:DeployMainnetScript --fork-url http://localhost:8545 --private-key $(PRIVATE_KEY_TESTNET) --broadcast

dev:
	forge script script/DeployDev.s.sol:DeployDevScript --fork-url http://localhost:8545 --private-key $(PRIVATE_KEY_TESTNET) --broadcast

anvil-testnet:
	anvil -m $(TESTNET_MNEMONIC)

anvil-arbitrum:	
	anvil --fork-url arbitrum

trace:
	forge test -vv

# Verify Contracts
#forge verify-contract --chain-id 42161 --watch --constructor-args $(cast abi-encode "constructor((string,string,address,uint256))" "("Share" "Token","STO",0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8,1000000000)") 0xb428cC8Fe759D79037355138cc0987F65f704587 src/Minter.sol:Minter QSWEZY6SZZ213F5748W3U7MKUAR7GGI7YB --verifier-url "https://api.arbiscan.io/api"
