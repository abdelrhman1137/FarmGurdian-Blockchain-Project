// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FarmGuardian {

    address public farmManager;
    
    mapping(address => bool) private trustedIoTDevices;

    mapping(bytes32 => address) public dataHashToDeviceAddress;
    
    uint256 public totalVerifiedRecords = 0;

    event DeviceAuthorized(address indexed device, address indexed authorizedBy);
    event TelemetryRecorded(bytes32 indexed dataHash, address indexed deviceId, uint256 timestamp);

    modifier onlyFarmManager() {
        require(msg.sender == farmManager, "FarmGuardian: Only the farm manager can call this function.");
        _;
    }

    modifier onlyTrustedDevice() {
        require(trustedIoTDevices[msg.sender] == true, "FarmGuardian: Sender is not an authorized IoT device.");
        _;
    }
    
    constructor() {
        farmManager = msg.sender;
    }

    function authorizeNewDevice(address _deviceAddress) public onlyFarmManager {
        require(_deviceAddress != address(0), "FarmGuardian: Invalid device address.");
        require(trustedIoTDevices[_deviceAddress] == false, "FarmGuardian: Device is already authorized.");
        
        trustedIoTDevices[_deviceAddress] = true;
        
        emit DeviceAuthorized(_deviceAddress, msg.sender);
    }
    
    function deauthorizeDevice(address _deviceAddress) public onlyFarmManager {
        require(_deviceAddress != address(0), "FarmGuardian: Invalid device address.");
        require(trustedIoTDevices[_deviceAddress] == true, "FarmGuardian: Device is not currently authorized.");
        
        trustedIoTDevices[_deviceAddress] = false;
    }
    
    function submitTelemetryData(uint256 _temp, uint256 _moisture, uint256 _phLevel) public onlyTrustedDevice {
        
        bytes32 dataHash = keccak256(abi.encodePacked(_temp, _moisture, _phLevel, msg.sender, block.timestamp));

        require(dataHashToDeviceAddress[dataHash] == address(0), "FarmGuardian: Exact telemetry record already exists.");

        dataHashToDeviceAddress[dataHash] = msg.sender;
        totalVerifiedRecords++;
        
        emit TelemetryRecorded(dataHash, msg.sender, block.timestamp);
    }

    function calculateHash(uint256 _temp, uint256 _moisture, uint256 _phLevel, address _sender, uint256 _timestamp) 
        public 
        pure 
        returns (bytes32) 
    {
        return keccak256(abi.encodePacked(_temp, _moisture, _phLevel, _sender, _timestamp));
    }

    function verifyDataIntegrity(uint256 _temp, uint256 _moisture, uint256 _phLevel, address _deviceAddress, uint256 _timestamp) 
        public 
        view 
        returns (bool isVerified) 
    {
        bytes32 expectedHash = calculateHash(_temp, _moisture, _phLevel, _deviceAddress, _timestamp);

        address recordedDevice = dataHashToDeviceAddress[expectedHash];

        return (recordedDevice == _deviceAddress) && (recordedDevice != address(0));
    }

    function getDeviceAddressByHash(bytes32 _dataHash) public view returns (address) {
        return dataHashToDeviceAddress[_dataHash];
    }
    
    function isDeviceAuthorized(address _address) public view returns (bool) {
        return trustedIoTDevices[_address];
    }
}
