import hre from "hardhat";
import { NativeBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { DECIMALS } from "./constant";

describe("NativeBank", () => {
  let signers: HardhatEthersSigner[];
  let nativeBankC: NativeBank;
  beforeEach("Deploy NativeBank contract", async () => {
    signers = await hre.ethers.getSigners();
    nativeBankC = await hre.ethers.deployContract("NativeBank");
  });

  it("Should send native token to contract", async () => {
    const staker = signers[0];

    const tx = {
      from: staker.address,
      to: await nativeBankC.getAddress(),
      value: hre.ethers.parseEther("1"),
    };
    const txResp = await staker.sendTransaction(tx);
    const txReceipt = await txResp.wait();
    console.log(
      // total balance
      await hre.ethers.provider.getBalance(await nativeBankC.getAddress()),
    );

    console.log(await nativeBankC.balanceOf(staker.address));
  });

  it("Should withdraw all the tokens", async () => {
    const staker = signers[0];
    const stakingAmount = hre.ethers.parseEther("10");
    const tx = {
      from: staker.address,
      to: await nativeBankC.getAddress(),
      value: stakingAmount,
    };
    const sentTx = await staker.sendTransaction(tx);
    sentTx.wait();
    expect(await nativeBankC.balanceOf(staker.address)).to.be.equal(
      stakingAmount,
    );

    await nativeBankC.withdraw();
    expect(await nativeBankC.balanceOf(staker.address)).to.be.equal(0n);
  });

  const unitParser = (amount: string) =>
    hre.ethers.parseUnits(amount, DECIMALS);
  const unitFormatter = (amount: bigint) =>
    hre.ethers.formatUnits(amount, DECIMALS);

  it("exploit", async () => {
    const victim1 = signers[1];
    const victim2 = signers[2];
    const hacker = signers[3];

    const exploitC = await hre.ethers.deployContract(
      "Exploit",
      [await nativeBankC.getAddress()],
      hacker,
    );
    const hcAddr = await exploitC.getAddress();
    const stakingAmount = unitParser("1");
    const v1Tx = {
      from: victim1.address,
      to: await nativeBankC.getAddress(),
      value: stakingAmount,
    };
    const v2Tx = {
      from: victim2.address,
      to: await nativeBankC.getAddress(),
      value: stakingAmount,
    };
    await victim1.sendTransaction(v1Tx);
    await victim2.sendTransaction(v2Tx);

    const getBalance = async (address: string) =>
      unitFormatter(
        await hre.ethers.provider.getBalance(address), //블록체인 네트워크에서 관리하는 잔액
      );

    console.log(await getBalance(hcAddr));
    await exploitC.exploit({ value: stakingAmount });
    console.log(await getBalance(hcAddr));
  });
});
