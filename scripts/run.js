const main = async () => {
    const [guy, randomGuy] = await hre.ethers.getSigners();
    const val = hre.ethers.utils;

    console.log("\n******************Deploying Contracts**********************");
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

    console.log("\n*********************Adding Liquid*************************");
    const _init = await dexContra.addLiquid(val.parseEther('5000'), val.parseEther('5000'));
    console.log("The lp amount now is", val.formatEther((await dexContra.lpAmount())));

    console.log("\n***********************Swaping***************************");
    const _swap = await dexContra.swap(TT1Contra.address, val.parseEther('1000'));
    console.log("amount 1 in lp:", val.formatEther(await TT1Contra.balanceOf(dexContra.address)),
     "amount 2 in lp:", val.formatEther(await TT2Contra.balanceOf(dexContra.address)));
    console.log("The lp amount now is", val.formatEther((await dexContra.lpAmount())));

    console.log("\n**********************Removing Liquid**************************");
    await dexContra.approve(dexContra.address, val.parseEther('1000000000'));
    const rmvlqd = await dexContra.removeLiquid(val.parseEther('5000000'));
    console.log("amount 1 in lp:", val.formatEther(await TT1Contra.balanceOf(dexContra.address)),
     "amount 2 in lp:", val.formatEther(await TT2Contra.balanceOf(dexContra.address)));
    console.log("The lp amount now is", val.formatEther((await dexContra.lpAmount())));

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