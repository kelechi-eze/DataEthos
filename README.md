# DataEthos

**Decentralized Genomic Data Marketplace**

DataEthos is a blockchain-based marketplace designed to securely manage, share, and monetize genomic data. Built in Clarity, it connects data providers and verified researchers through transparent access requests, ownership validation, and controlled data usage permissions.

## Key Features

* **Dataset Tokenization:** Converts genomic datasets into verifiable on-chain assets with metadata and encrypted data hashes.
* **Researcher Identity System:** Registers and verifies researchers with institutional credentials and a dynamic reputation score.
* **Access Request Protocol:** Enables researchers to request access to datasets, while owners maintain full control over approvals.
* **Payment and Access Logging:** Tracks dataset ownership, researcher permissions, and access status to ensure transparent data usage.
* **Governance and Verification:** Contract owner oversees researcher verification and reputation updates to maintain ecosystem trust.

## Contract Components

* **Data Variables:**

  * `dataset-count` – Tracks total number of datasets listed on the marketplace.

* **Maps:**

  * `datasets` – Stores details of each dataset, including hashes, price, and owner.
  * `researchers` – Holds researcher profiles, verification status, and reputation scores.
  * `access-requests` – Records pending and approved dataset access requests.
  * `dataset-access` – Tracks researcher permissions for each dataset.
  * `researcher-contributions` – Keeps a record of researcher activity levels.

## Core Functions

* `register-dataset(encrypted-data-hash, metadata-hash, price)` – Registers new genomic datasets with metadata and price.
* `register-researcher(name, institution, credentials)` – Creates a verified identity profile for researchers.
* `request-access(dataset-id)` – Allows researchers to request access to available datasets.
* `approve-access(dataset-id, request-id)` – Enables dataset owners to approve researcher access.
* `verify-researcher(researcher)` – Grants verified status to researchers by the contract owner.
* `update-reputation(researcher, score)` – Adjusts researcher reputation score based on contributions or performance.

## Read-Only Functions

* `get-dataset-details(dataset-id)` – Returns metadata and price for a dataset.
* `get-researcher-profile(researcher)` – Retrieves a researcher’s name, institution, credentials, and score.
* `get-access-status(dataset-id, researcher)` – Checks whether a researcher has approved access to a dataset.
