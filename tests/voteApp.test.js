// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VoteApp", function () {
  it("test initialzatrion", async function () {
    const VoteApp = await ethers.getContractFactory("VoteApp");
    const voteAppToTest = await VoteApp.deploy();
    await voteAppToTest.deployed();
    console.log('VoteApp deployed at:'+ voteAppToTest.address);
    console.log('Amount raised is: ' + voteAppToTest.raisedAmount());

  });
  /**
   it("test updating and retrieving updated value", async function () {
    const VoteApp = await ethers.getContractFactory("VoteApp");
    const voteAppToTest = await VoteApp.deploy();
    await voteAppToTest.deployed();
    const storage2 = await ethers.getContractAt("Storage", storage.address);
    const setValue = await storage2.store(56);
    await setValue.wait();
    expect((await storage2.retrieve()).toNumber()).to.equal(56);
  });
  */
});