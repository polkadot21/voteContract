// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VoteApp", function () {

  before(async function() {
    const VoteApp = await ethers.getContractFactory("VoteApp");
    const voteAppToTest = await VoteApp.deploy();
    await voteAppToTest.deployed();
  })

  it("test addresses", async function () {
    console.log('VoteApp deployed at:'+ voteAppToTest.address);
    console.log('VoteApp contract address is: ' + await voteAppToTest.contractAddress());
    expect(voteAppToTest.address).to.eql(await voteAppToTest.contractAddress());
  });

  it ("test initial raised Amount", async function() {
    console.log("Initial raised Amount is equal to: " + await voteAppToTest.raisedAmount())
    expect(await voteAppToTest.raisedAmount()).to.equal(0);
  });

  /*it ("test contirbution amount", async function () {
    console.log("Contirbution amount is equal to: " + await voteAppToTest.contributionAmount());
    expect(await voteAppToTest.contributionAmount()).to.eql("10000000000000000");

  });*/

  it ("test the deadline", async function() {
    console.log('Voting ends in: ' + await voteAppToTest.deadline());
    expect(await voteAppToTest.deadline()).to.eq(1656188352)
  });


});