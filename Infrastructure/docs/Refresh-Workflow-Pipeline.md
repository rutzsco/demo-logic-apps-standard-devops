# Updating Logic App Repository

This pipeline will scan an existing Logic App in the Azure portal and pull down the source code for that application into a local repository.  

---

**Step 1:** Initialize: An admin will fork this repo and set up pipelines.
![Workflow](images/LogicAppWorkflow1.png)

**Step 2:** Design: User will design the logic app in the Azure portal. Once they are complete, they will trigger refresh workflow.
![Workflow](images/LogicAppWorkflow2.png)

**Step 3:** Deploy: Click New pipeline from the Pipeline section of the Azure DevOps project

![Workflow](images/LogicAppWorkflow3.png)
