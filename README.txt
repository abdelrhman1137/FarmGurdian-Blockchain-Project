-FarmGuardian Smart Contract: Decentralized IoT Data Integrity

The `FarmGuardian` contract establishes a **secure, immutable, and auditable ledger** for telemetry data submitted by authorized IoT devices on a farm. It guarantees that environmental records (Temperature, Moisture, pH) are verifiably submitted by a trusted source at a specific time, protecting against tampering and data falsification.



-Core Functionality & Access Control

| Feature | Description | Access Restriction |
| :--- | :--- | :--- |
| **Farm Manager** | The manager controls device access and serves as the single point of authority (`onlyFarmManager`). | Deployer (`constructor`) |
| **Device Authorization** | Manager adds/removes devices from the **Trusted Registry** (`trustedIoTDevices`). | `onlyFarmManager` |
| **Data Submission** | Authorized devices submit data which is hashed (`keccak256`) along with the sender and timestamp. | `onlyTrustedDevice` |
| **Data Immutability** | A unique **Hash-to-Device mapping** (`dataHashToDeviceAddress`) is created, ensuring that the exact record cannot be submitted twice. | Internal (`submitTelemetryData`) |
| **External Verification** | Any party can publicly re-calculate the expected data hash and verify its integrity and origin against the recorded ledger. | Public (`verifyDataIntegrity`) |

-Key Concepts

-Hashing for Integrity
When a trusted device calls `submitTelemetryData(T, M, P)`, the contract calculates:
$$
\text{Hash} = \text{keccak256}(\text{T}, \text{M}, \text{P}, \text{Sender Address}, \text{Timestamp})
$$
This cryptographic hash acts as the **digital fingerprint** of the data, which is then permanently stored on the blockchain, linked to the sending device.

-Auditable Record Flow

1.  **Authorization:** Farm Manager $\rightarrow$ `authorizeNewDevice(Device\_A)`
2.  **Submission:** Device\_A $\rightarrow$ `submitTelemetryData(15, 60, 6.5)`
3.  **Record:** Contract stores $\text{Hash}_{\text{A}} \rightarrow \text{Device\_A}$
4.  **Verification:** External Auditor $\rightarrow$ `verifyDataIntegrity(15, 60, 6.5, Device\_A, Timestamp)` $\rightarrow$ **True** (Confirmed)

-Public Interface

* `submitTelemetryData()`: Used by authorized sensors to record data.
* `verifyDataIntegrity()`: Publicly verifies if a set of data was genuinely recorded by a specified device at a given time.
* `getDeviceAddressByHash()`: Retrieves the original submitter of a specific data hash.
