require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
const { MINT_START_UNIX_TIMESTAMP, MINT_END_UNIX_TIMESTAMP, META_DATA_URL } =
  process.env;

async function main() {
  const MyNFT = await ethers.getContractFactory("NFT_Minting_With_Date_Range");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy(
    MINT_START_UNIX_TIMESTAMP,
    MINT_END_UNIX_TIMESTAMP,
    META_DATA_URL
  );

  await myNFT.deployed();
  console.log("Contract deployed to address:", myNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
