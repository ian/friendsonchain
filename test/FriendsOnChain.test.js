const { ethers } = require("hardhat")
const { deployContract } = require("./helpers.js")
const { expect } = require("chai")

describe("FriendsOnChain", () => {
  beforeEach(async function () {
    const [owner, addr1, addr2] = await ethers.getSigners()
    this.owner = owner
    this.addr1 = addr1
    this.addr2 = addr2

    this.contract = await deployContract("FriendsOnChain", [])
  })

  context("createGroup()", async function () {
    context("error cases", async function () {
      it("errors when the wrong amount of ether is sent", async function () {
        await this.contract.setPrice(ethers.utils.parseUnits("1.00", "ether"))
        await expect(
          this.contract.createGroup([this.addr1.address], {
            value: 0
          })
        ).to.be.reverted
      })

      // it("errors when too many addresses are specified", async function () {
      //   expect(
      //     this.contract.createGroup([this.addr1.address], "bafybeiekovx3i2bg2agc3rza3xbjabt4jg7wyg2uwxb5iv74kpz6zerure", {
      //       value: 0
      //     })
      //   ).to.be.revertedWith("Ether value sent is not correct")
      // })
    })

    it("fires the GroupCreate event", async function () {
      expect(
        this.contract
          .connect(this.addr1)
          .createGroup([this.addr1.address])
          .then((res) => res.wait())
      )
        .to.emit(this.contract, "GroupCreate")
        .withArgs("1", [this.addr1.address])
    })

    context("successfully", async function () {})
  })

  context("countGroups", async function () {
    it("has 0 groups by default", async function () {
      const countGroups = await this.contract.countGroups()
      expect(countGroups).to.equal(0)
    })

    context("after createGroup", async function () {
      beforeEach(async function () {
        await this.contract
          .connect(this.addr1)
          .createGroup([this.addr1.address])
      })

      it("countGroups is 1", async function () {
        const countGroups = await this.contract.countGroups()
        expect(countGroups).to.equal(1)
      })
    })
  })

  context("price", async function () {
    context("defaults", async function () {
      it("has the correct price", async function () {
        const price = await this.contract.price().then((res) => res / 1e18)
        expect(price).to.equal(0)
      })
    })

    it("should allow the price to be changed", async function () {
      expect(await this.contract.price()).to.equal(
        ethers.utils.parseUnits("0.00", "ether")
      )

      await this.contract.setPrice(ethers.utils.parseUnits("1.00", "ether"))

      expect(await this.contract.price()).to.equal(
        ethers.utils.parseUnits("1.00", "ether")
      )
    })
  })

  context("isMember", async function () {
    context("by default", async function () {
      it("should not be a member", async function () {
        expect(await this.contract.isMember(this.addr1.address, "1")).to.equal(
          false
        )
      })
    })
    context("after createGroup", async function () {
      beforeEach(async function () {
        await this.contract
          .connect(this.addr1)
          .createGroup([this.addr1.address])
      })

      it("isMember is true", async function () {
        expect(await this.contract.isMember(this.addr1.address, "1")).to.equal(
          true
        )
        expect(await this.contract.isMember(this.addr2.address, "1")).to.equal(
          false
        )
      })
    })
  })
})
