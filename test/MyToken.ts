import hre from "hardhat";
import { expect } from "chai";
import { MyToken } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
// hardhat에서 컴파일 할 때 필요한 타입 정의 파일을 여기에 보관함

describe("mytoken deploy", () => {
  let myTokenC: MyToken;
  let signers: HardhatEthersSigner[];

  // before > describe, let myTokenC > myTokenC 사용ok
  before("should deploy", async () => {
    signers = await hre.ethers.getSigners();
    myTokenC = await hre.ethers.deployContract("MyToken", [
      "MyToken",
      "MT",
      18,
    ]);
  });

  it("should return name", async () => {
    expect(await myTokenC.name()).equal("MyToken");
  });
  it("should return symbol", async () => {
    expect(await myTokenC.symbol()).equal("MT");
  });
  it("should return decimals", async () => {
    expect(await myTokenC.decimals()).equal(18);
  });
  it("should retrun 0 totalSupply", async () => {
    expect(await myTokenC.totalSupply()).equal(0);
  });
  it("should retrun 0 balance for signer 0", async () => {
    expect(await myTokenC.balanceOf(signers[0].address)).equal(0);
    const signer0 = signers[0];
    expect(await myTokenC.balanceOf(signer0)).equal(0);
  });
});
