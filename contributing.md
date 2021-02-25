# Contributing to podtato head


## Contributing an implementation for a delivery tool

If you want to create support for an additional delivery tool. Please create an issue and a PR with your changes. Currently we still need to manually verify if the use case working, so please test thoroughly.

People are using these examples to learn how to use a delivery tool. Keep in mind that this will also be the (first) way they learn how to use your tool. Please write the examples with this in mind (explain what is created and why, ...) Each example should cover the following steps:

* Setup and deployment of the delivery tool. Ideally, this can be done on a local machine with Kind, minikube, ...
* Onboarding the podtato-head application. If you need specifc modifications from the standard manifest please describe them. 
* Deploying the first version version of the service
* Show how to access the service and validate whether it works
* Show how to upgrade the service to a new version 
* Show how to uninstall the everything again. Many people are using this for learning and want to get back to the before state easily. 

Additionally there are some more items you can provide to make your examples better:

* Provide a command line script to run all the example steps. Most people copy and past them anyway. Going forward this will also help to automatically test the examples. The following format for a step works great as it output and executes a command. 
  ``` 
      if [$command -eq onboard] 
        echo command_to_execute
        command to execute
      fi
  ```
 * Tell people where they can reach out. They might want to learn more about your tool. Make it easy for them. 
 * If you have a video walkthrough of the example - great!

## Contributing to the podtato head app

If you have a new use cases in mind (e.g. adding an additonal service, ....) please create an issue and describe how the use case should work. As we want to keep the ``` main ``` branch as a working version we will create a decidated branch for new use cases. 

## General discussion 

For general discussions please join the CNCF SIG App Delivery [Slack channel](https://cloud-native.slack.com/archives/CL3SL0CP5) 
