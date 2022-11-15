const main = async () => {
    const [guy, randomGuy] = await hre.ethers.getSigners();
    const val = hre.ethers.utils;

    const TT1Fac = await hre.ethers.getContractFactory("TestToken1");
    const TT1Contra = await TT1Fac.deploy();
    console.log("TT1 has been deployed to", TT1Contra.address);

    const TT2Fac = await hre.ethers.getContractFactory("TestToken2");
    const TT2Contra = await TT2Fac.deploy();
    console.log("TT2 has been deployed to", TT2Contra.address);

    const dexFac = await hre.ethers.getContractFactory("Xyzswap");
    const dexContra = await dexFac.deploy(TT1Contra.address, TT2Contra.address);
    console.log("Dex has been deployed to", dexContra.address);

    const approve1 = await TT1Contra.approve(dexContra.address, val.parseEther('10000'));
    const approve2 = await TT2Contra.approve(dexContra.address, val.parseEther('10000'));

    const _init = await dexContra.addLiquid(val.parseEther('5000'), val.parseEther('5000'));
    console.log("The lp amount now is", val.formatEther((await dexContra.balanceOf(guy.address))));

    const _swap = await dexContra.swap(TT1Contra.address, val.parseEther('1000'));
    console.log("amount 1:", val.formatEther(await TT1Contra.balanceOf(guy.address)),
     "amount 2:", val.formatEther(await TT2Contra.balanceOf(guy.address)));
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