
# Examples

## Evaluation 

### Analytic

* test-report-PKPD_analytic_1_dose.R: phiD identiques
* test-report-PKPD_analytic_multi_doses.R: phiD identiques
* test-report-PKPD_analytic_repetead_doses.R: phiD identiques

### Analytic infusion

* test-report-PKPD_analytic_Infusion_1_dose.R: phiD identiques
* test-report-PKPD_analytic_Infusion_multi_dose.R: phiD identiques
* test-report-PKPD_analytic_Infusion_repeated_dose.R: phiD identiques

### ODE

* test-report-PKPD_ode_1_dose.R: phiD identiques
* test-report-PKPD_ode_1_dose_BolusTurn.R: 
  *  Population: phiD = 630.4746 alors que avant 898.2745 
  *  Individual: phiD = 53.64869 alors que avant 95.31133
  *  Bayesian: phiD = 752.7777 alors que avant 953.7154 
  *  Sur les plots RespPK et RespPD, il y a des points correspondant aux temps de dose alors que normalement ce ne sont pas des temps d'observation
* test-report-PKPD_ode_multi_doses.R: 
  *  Population: phiD a changé d'un pouième ( 953.8621 contre 953.8866 )
  *  Individual: phiD a changé d'un pouième  ( 129.6387 contre 129.6418  )
  *  Bayesian:  phiD a changé d'un pouième  ( 675.8462 contre  675.8371 )
* test-report-PKPD_ode_repetead_doses.R: 
  *  Population: phiD a changé d'un pouième ( 567.4917 contre 567.2435 )
  *  Individual: phiD a changé d'un pouième  ( 82.02712 contre 81.98873 )
  *  Bayesian:  phiD a changé d'un pouième  ( 487.6914 contre  487.6901 )
* test-report-PKPD_ode_repetead_doses_Clozapine.R: 
  *  Population: phiD = 5.626805  alors que avant 0.0346774
  *  Individual: phiD = 0.3188598  alors que avant 0.0015522 
  *  Bayesian: phiD = 127.7094 alors que avant 0.016529
  
### ODE infusion

* test-report-PK_ode_infusion_1_dose.R: phiD identiques
* test-report-PKPD_ode_infusion_1_dose.R: 
  *  Population: phiD = 1640.606 alors que avant 720.1697 
  *  Individual: phiD = 100.2911 alors que avant 36.43874 
  *  Bayesian: phiD = 970.3904 alors que avant 519.0389 
* test-report-PKPD_ode_infusion_multi_doses.R: phiD identiques
* test-report-PKPD_ode_infusion_repetead_doses.R: phiD identiques
* test-report-PKPKPD_ode_infusion_1_dose.R: 
  *  Population: phiD = 387.2427 alors que avant 134.7527 
  *  Individual: phiD = 25.66667 alors que avant 8.944507 
  *  Bayesian: phiD = 435.6958  alors que avant 351.1272 






