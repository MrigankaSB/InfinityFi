const { ethers } = require("hardhat");

async function main() {
  const InfinityFi = await ethers.getContractFactory("InfinityFi");
  const infinityFi = await InfinityFi.deploy();

  await infinityFi.deployed();

  console.log("InfinityFi contract deployed to:", infinityFi.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
