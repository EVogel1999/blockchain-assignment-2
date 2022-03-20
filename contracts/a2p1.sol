//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CISEnrollment {
    enum EnrollmentType { UNDERGRADUATE, GRADUATE }

    struct Course {
        uint256 number;
        EnrollmentType courseType;
        bool gradsCanEnroll;
        bool exists;
    }

    struct Registered {
        address id;
        uint256 courseNum;
        uint256 timestamp;
        uint256 credits;
        bool exists;
    }

    struct Student {
        address id;
        uint256 credits;
        bool exists;
    }
    
    // Variables
    address private owner;
    mapping (uint256 => Course) public catalogue;
    mapping (address => Student) public students;
    Registered[] private registered;
    uint private MAX_ENROLLED = 30;

    constructor() {
        owner = msg.sender;
        catalogue[670] = Course(670, EnrollmentType.GRADUATE, true, true);
        catalogue[617] = Course(617, EnrollmentType.GRADUATE, true, true);
        catalogue[484] = Course(484, EnrollmentType.UNDERGRADUATE, true, true);
        catalogue[431] = Course(431, EnrollmentType.UNDERGRADUATE, false, true);
    }

    // Public Functions
    function register(uint credits, EnrollmentType studentType, uint256 course) public CourseExists(course) CheckStudentExists CheckCourseRestrictions(studentType, course) {
        Course memory c = catalogue[course];
        require(getNumberEnrolledStudents(course) < MAX_ENROLLED);

        // If the student is a grad student and enrolling in a undergrad course
        if (studentType == EnrollmentType.GRADUATE && studentType != c.courseType) {
            require(students[msg.sender].exists && students[msg.sender].credits > 20);
        }

        require(!checkStudentIsEnrolled(course));

        enrollStudent(course, credits);
    }

    function add(uint256 courseNum, EnrollmentType courseType) public CourseDoesntExist(courseNum) {
        require(msg.sender == owner);
        catalogue[courseNum] = Course(courseNum, courseType, true, true);
    }

    function getRoster(uint256 courseNum) public view CourseExists(courseNum) {
        for (uint i = 0; i < registered.length; i++) {
            if (registered[i].exists && registered[i].courseNum == courseNum) {
                console.log(registered[i].id);
            }
        }
    }

    function drop(uint256 course) public CheckStudentExists CourseExists(course) {
        require(checkStudentIsEnrolled(course));
        
        // Find the Registered struct
        Registered memory r;
        uint index;
        for (uint256 i = 0; i < registered.length; i++) {
            if (registered[i].id == msg.sender && registered[i].courseNum == course) {
                r = registered[i];
                index = i;
            }
        }

        // Check time requirement
        require (block.timestamp - (60*30) < r.timestamp);

        // Drop the course
        students[msg.sender].credits -= r.credits;
        for (uint256 i = index; i < registered.length - 1; i++) {
            registered[i] = registered[i + 1];
        }
        delete registered[registered.length - 1];
    }

    // Private Functions
    function getNumberEnrolledStudents(uint256 course) private view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < registered.length; i++) {
            if (registered[i].exists && registered[i].courseNum == course) {
                total++;
            }
        }
        return total;
    }

    function enrollStudent(uint256 course, uint256 credits) private {
        registered.push(Registered(msg.sender, course, block.timestamp, credits, true));
        students[msg.sender].credits += credits;
    }

    function checkStudentIsEnrolled(uint256 course) private view returns (bool) {
        bool found = false;
        for (uint i = 0; i < registered.length; i++) {
            if (registered[i].id == msg.sender && registered[i].courseNum == course) {
                found = true;
            }
        }
        return found;
    }

    // Modifiers
    modifier CourseExists(uint256 course) {
        require(catalogue[course].exists);
        _;
    }

    modifier CourseDoesntExist(uint256 course) {
        require(!catalogue[course].exists);
        _;
    }

    modifier CheckCourseRestrictions(EnrollmentType studentType, uint256 course) {
        Course memory c = catalogue[course];
        if (studentType == EnrollmentType.UNDERGRADUATE) {
            require(c.courseType == studentType);
        } else {
            require(c.gradsCanEnroll);
        }
        _;
    }

    modifier CheckStudentExists() {
        if (!students[msg.sender].exists) {
            students[msg.sender] = Student(msg.sender, 0, true);
        }
        _;
    }
}