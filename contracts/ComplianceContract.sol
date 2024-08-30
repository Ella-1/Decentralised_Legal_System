// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ComplianceChecker {
    struct ComplianceReport {
        address contractAddress;
        string reportHash; // Hash of compliance check report
        bool isCompliant;
        string feedback;
    }

    mapping(address => ComplianceReport) public complianceReports;

    event ComplianceChecked(address indexed contractAddress, bool isCompliant, string reportHash);

    // Function to perform a compliance check
    function checkCompliance(address _contractAddress, string memory _reportHash, bool _isCompliant, string memory _feedback) external {
        complianceReports[_contractAddress] = ComplianceReport({
            contractAddress: _contractAddress,
            reportHash: _reportHash,
            isCompliant: _isCompliant,
            feedback: _feedback
        });

        emit ComplianceChecked(_contractAddress, _isCompliant, _reportHash);
    }

    // Function to retrieve a compliance report
    function getComplianceReport(address _contractAddress) external view returns (ComplianceReport memory) {
        return complianceReports[_contractAddress];
    }
}
