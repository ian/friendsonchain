const { ethers } = require("hardhat")
const { deployContract } = require("./helpers.js")
const { expect } = require("chai")

describe("GroupPass", () => {
  beforeEach(async function () {
    const [owner, addr1, addr2] = await ethers.getSigners()
    this.owner = owner
    this.addr1 = addr1
    this.addr2 = addr2

    this.contract = await deployContract("GroupPass", [])
  })

  context("default deployment", async function () {
    it("has 0 totalMinted", async function () {
      const totalMinted = await this.contract.totalMinted()
      expect(totalMinted).to.equal(0)
    })

    it("has the correct price", async function () {
      const price = await this.contract.price().then((res) => res / 1e18)
      expect(price).to.equal(0)
    })
  })

  context("changing properties", async function () {
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

  context("mint()", async function () {
    context("error cases", async function () {
      it("errors when the wrong amount of ether is sent", async function () {
        this.contract.setPrice(1 * 1e18)
        expect(
          this.contract.mint([this.addr1.address], {
            value: 0
          })
        ).to.be.revertedWith("Ether value sent is not correct")
      })

      it("errors when too many addresses are specified", async function () {
        expect(
          this.contract.mint([this.addr1.address], {
            value: 0
          })
        ).to.be.revertedWith("Ether value sent is not correct")
      })
    })

    context("successfully minting", async function () {
      beforeEach(async function () {
        await this.contract.connect(this.addr1).mint([this.addr1.address])
      })

      it("has 1 totalMinted", async function () {
        const totalMinted = await this.contract.totalMinted()
        expect(totalMinted).to.equal(1)
      })

      it("has 1 token minted to the address specified", async function () {
        const balanceOf = await this.contract.balanceOf(this.addr1.address, "1")
        expect(balanceOf).to.equal(1)
      })
    })
  })

  context("pausing", async function () {
    it("should be unpaused by default", async function () {
      const paused = await this.contract.paused()
      expect(paused).to.equal(false)
    })

    it("should be pausable / unpausable", async function () {
      await this.contract.pause()
      expect(await this.contract.paused()).to.equal(true)
      await this.contract.unpause()
      expect(await this.contract.paused()).to.equal(false)
    })

    it("should disallow mint() on paused contracts", async function () {
      expect(() => this.contract.mint([this.addr1.address])).not.to.throw()

      await this.contract.pause()

      expect(this.contract.mint([this.addr1.address])).to.be.revertedWith()
    })
  })
})
