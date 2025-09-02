/* AWF Design MySQL */

-- Workflow template definition
CREATE TABLE awfWorkflowTemplate (
  workflowTemplateId VARCHAR(30) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Step template inside a workflow
CREATE TABLE awfWorkflowStepTemplate (
  stepTemplateId VARCHAR(30) PRIMARY KEY,
  workflowTemplateId VARCHAR(30) NOT NULL,
  stepOrder INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  actionType VARCHAR(30) NOT NULL,       -- API / SQS / SQL / MANUAL
  actionConfig JSON NULL,                -- URL, query, queue name, etc.
  approvalMode VARCHAR(20) NOT NULL DEFAULT 'ALL', -- ALL / ANY / QUORUM
  quorumCount INT NULL,                  -- used if approvalMode = QUORUM
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (workflowTemplateId) REFERENCES awfWorkflowTemplate(workflowTemplateId)
);

-- Approver template for each workflow step
CREATE TABLE awfStepApproverTemplate (
  approverTemplateId VARCHAR(30) PRIMARY KEY,
  stepTemplateId VARCHAR(30) NOT NULL,
  approverId VARCHAR(30) NOT NULL,      -- userId or roleId
  approverType VARCHAR(20) NOT NULL DEFAULT 'USER', -- USER / ROLE / DYNAMIC
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (stepTemplateId) REFERENCES awfWorkflowStepTemplate(stepTemplateId)
);

-- Workflow request instance
CREATE TABLE awfRequest (
  reqId VARCHAR(30) PRIMARY KEY,
  workflowTemplateId VARCHAR(30) NOT NULL,
  title VARCHAR(100) NOT NULL,
  description TEXT NULL,
  payload JSON NOT NULL,
  headers JSON NULL,
  requestorId VARCHAR(30) NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING / APPROVED / REJECTED / RUNNING
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (workflowTemplateId) REFERENCES awfWorkflowTemplate(workflowTemplateId)
);

-- Workflow step instance for a request
CREATE TABLE awfRequestStep (
  reqStepId VARCHAR(30) PRIMARY KEY,
  reqId VARCHAR(30) NOT NULL,
  stepTemplateId VARCHAR(30) NOT NULL,
  stepOrder INT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING / APPROVED / REJECTED / RUNNING / SKIPPED
  approvalMode VARCHAR(20) NOT NULL,
  quorumCount INT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (reqId) REFERENCES awfRequest(reqId),
  FOREIGN KEY (stepTemplateId) REFERENCES awfWorkflowStepTemplate(stepTemplateId)
);

-- Approver instance for each step in a request
CREATE TABLE awfRequestStepApprover (
  reqStepApproverId VARCHAR(30) PRIMARY KEY,
  reqStepId VARCHAR(30) NOT NULL,
  approverId VARCHAR(30) NOT NULL,
  approverType VARCHAR(20) NOT NULL DEFAULT 'USER', -- USER / ROLE / DYNAMIC
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',   -- PENDING / APPROVED / REJECTED / SKIPPED
  actedAt TIMESTAMP NULL,
  FOREIGN KEY (reqStepId) REFERENCES awfRequestStep(reqStepId)
);
