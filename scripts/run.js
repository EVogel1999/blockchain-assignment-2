const main = async () => {
  const cisEnrollmentFactory = await hre.ethers.getContractFactory('CISEnrollment');
  const enrollmentContract = await cisEnrollmentFactory.deploy();
  await enrollmentContract.deployed();
  console.log('Contract deployed to:', enrollmentContract.address);

  await testRegister(enrollmentContract);
};

async function testRegister(enrollmentContract) {
  await enrollmentContract.register(3, 0, 484);
}
  
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};
  
runMain();