import hre from "hardhat";
import { expect } from "chai";
import { DECIMALS, MINTING_AMOUNT } from "./constant";
import { MyToken, TinyBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("TinyBank", () => {
  let signers: HardhatEthersSigner[];
  let myTokenC: MyToken;
  let tinyBankC: TinyBank;

  beforeEach(async () => {
    signers = await hre.ethers.getSigners();
    myTokenC = await hre.ethers.deployContract("MyToken", [
      "MyToken",
      "MT",
      DECIMALS,
      MINTING_AMOUNT, //100MT 발행했었다
    ]);
    tinyBankC = await hre.ethers.deployContract("TinyBank", [
      await myTokenC.getAddress(),
      [
        signers[0].address,
        signers[1].address,
        signers[2].address,
        signers[3].address,
        signers[4].address,
      ],
    ]);
    await myTokenC.setManager(tinyBankC.getAddress());
  });

  describe("Initialized state check", () => {
    it("should return totalStaked 0", async () => {
      expect(await tinyBankC.totalStaked()).equal(0);
    });
    it("should return staked 0 amount of signer0", async () => {
      const signer0 = signers[0];
      expect(await tinyBankC.staked(signer0.address)).equal(0);
    });
  });

  describe("Staking", async () => {
    it("should return staked amount", async () => {
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await tinyBankC.stake(stakingAmount);
      expect(await tinyBankC.staked(signer0.address)).equal(stakingAmount);
      expect(await tinyBankC.totalStaked()).equal(stakingAmount);
      expect(await myTokenC.balanceOf(tinyBankC)).equal(
        await tinyBankC.totalStaked(),
      );
    });
  });

  describe("Withdraw", async () => {
    it("should return 0 staked after withdrawing total token", async () => {
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await tinyBankC.stake(stakingAmount);
      await tinyBankC.withdraw(stakingAmount);
      expect(await tinyBankC.staked(signer0.address)).equal(0);
    });
  });

  describe("reward", async () => {
    it("should reward 1MT every blocks", async () => {
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await tinyBankC.stake(stakingAmount);
      const BLOCKS = 5n;
      const transferAmount = hre.ethers.parseUnits("1", DECIMALS);
      for (var i = 0; i < BLOCKS; i++) {
        await myTokenC.transfer(transferAmount, signer0.address);
      }
      await tinyBankC.withdraw(stakingAmount);
      expect(await myTokenC.balanceOf(signer0.address)).equal(
        hre.ethers.parseUnits((BLOCKS + MINTING_AMOUNT + 1n).toString()),
      );
    });

    it("should update rewardPerBlock and reward 10MT every blocks when all managers confirm", async () => {
      const rewardToChange = hre.ethers.parseUnits("10", DECIMALS);
      const MANAGER_NUMBERS = 5;
      // 매니저 전부 동의
      for (var i = 0; i < MANAGER_NUMBERS; i++) {
        await tinyBankC.connect(signers[i]).confirm();
      }
      // reward 변경
      await tinyBankC.connect(signers[0]).setRewardPerBlock(rewardToChange);

      // reward 적용 확인
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await tinyBankC.stake(stakingAmount);
      const BLOCKS = 5n;
      const transferAmount = hre.ethers.parseUnits("1", DECIMALS);
      for (var i = 0; i < BLOCKS; i++) {
        await myTokenC.transfer(transferAmount, signer0.address);
      }
      await tinyBankC.withdraw(stakingAmount);
      const expectedBalance = 10n * (BLOCKS + 1n) + MINTING_AMOUNT;
      expect(await myTokenC.balanceOf(signer0.address)).equal(
        hre.ethers.parseUnits(expectedBalance.toString()),
      );
    });

    it("should revert if not all managers confirm", async () => {
      const rewardToChange = hre.ethers.parseUnits("1000", DECIMALS);
      const MANAGER_NUMBERS = 5;
      // 매니저 중 일부만 confirm
      for (var i = 0; i < MANAGER_NUMBERS - 3; i++) {
        await tinyBankC.connect(signers[i]).confirm();
      }
      await expect(
        tinyBankC.setRewardPerBlock(rewardToChange),
      ).to.be.revertedWith("Not all confirmed yet");
    });

    it("Should revert when access confirm by hacker", async () => {
      const hacker = signers[9];
      await expect(tinyBankC.connect(hacker).confirm()).to.be.revertedWith(
        "You are not a managers",
      );
    });

    it("Should revert when changing rewardPerBlock by hacker", async () => {
      const hacker = signers[9];
      const rewardToChange = hre.ethers.parseUnits("10000", DECIMALS);
      await expect(
        tinyBankC.connect(hacker).setRewardPerBlock(rewardToChange),
      ).to.be.revertedWith("You are not a managers");
    });
  });
}); //root grouping
