const main = async () => {
  const cisEnrollmentFactory = await hre.ethers.getContractFactory('CISEnrollment');
  const enrollmentContract = await cisEnrollmentFactory.deploy();
  await enrollmentContract.deployed();
  console.log('Contract deployed to:', enrollmentContract.address);

  await testRegister(enrollmentContract);
  await testAddCourse(enrollmentContract);
};

async function testRegister(enrollmentContract) {
  console.log('Testing register(credits, type, course):');
  await enrollmentContract.register(3, 0, 484).then(_ => console.log('1. Undergrad enrolled correctly'));
  await enrollmentContract.register(3, 1, 617).then(_ => console.log('2. Grad enrolled correctly'));
  await enrollmentContract.register(3, 0, 484).catch(_ => console.log('3. Caught undergrad trying to enroll in a class they are already enrolled in'));
  await enrollmentContract.register(3, 1, 484).catch(_ => console.log('4. Caught grad trying to enroll in an undergrad class with less then 20 credits'));
  await enrollmentContract.register(3, 0, 617).catch(_ => console.log('5. Caught undergrad trying to enroll in grad course'));
  await enrollmentContract.register(3, 1, 431).catch(_ => console.log('6. Caught grad trying to enroll in 431'));
  await enrollmentContract.register(3, 0, 336).catch(_ => console.log('7. Caught undergrad trying to enroll in a course that doesn\'t exist'));

  // for(let i = 0; i < 31; i++) {
  //   await enrollmentContract.register(3, 1, 670).catch(_ => console.log('8. Caught trying to enroll in a full class'));
  // }

  console.log();
}

async function testAddCourse(enrollmentContract) {
  console.log('Testing add(courseNum, courseType):');
  await enrollmentContract.add(336, 0).then(_ => console.log('1. Contract owner could create a course that doesn\'t exist'));
  await enrollmentContract.add(336, 0).catch(_ => console.log('2. Contract owner could not create a course that does exist'));

  console.log();
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