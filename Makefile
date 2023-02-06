# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

deploy-arbitrum:; forge script script/Minter.s.sol:MinterScript --rpc-url $(ARBITRUM_ONE_RPC_URL)  --private-key $(PRIVATE_KEY) --broadcast --verify

deploy-test:; forge script script/Minter.s.sol:MinterScript --fork-url http://localhost:8545 --private-key $(PRIVATE_KEY) --broadcast

dev:
	forge script script/DeployDev.s.sol:DeployDev --fork-url http://localhost:8545 --private-key $(PRIVATE_KEY) --broadcast

anvil-arbitrum:; anvil --fork-url arbitrum

trace:; forge test -vv
