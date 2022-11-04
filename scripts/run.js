const main = async () => {
    const TT1Fac = await hre.ethers.getContractFactory("TestToken1");
    const TT1Contra = await TT1Fac.deploy();
    console.log("TT1 has been deployed to", TT1Contra.address);

    const TT2Fac = await hre.ethers.getContractFactory("TestToken2");
    const TT2Contra = await TT2Fac.deploy();
    console.log("TT2 has been deployed to", TT2Contra.address);

    const dexFac = await hre.ethers.getContractFactory("Xyzswap");
    const dexContra = await dexFac.deploy();
    console.log("Dex has been deployed to", dexContra.address);
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    }
    catch(error) {
        console.log(error);
        process.exit(-1);
    }
}

runMain();