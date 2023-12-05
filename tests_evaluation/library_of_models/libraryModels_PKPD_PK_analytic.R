######################################################

# PKPD
# PK : analytic

######################################################

modelPKType = c("analytic")
modelPKAdmin = c("bolus","infusion","firstOrder")
modelPDType = c("analytic","ode")
expand.grid(modelPKType, modelPKAdmin,modelPDType)

# 1 analytic      bolus analytic
# 2 analytic   infusion analytic
# 3 analytic firstOrder analytic
# 4 analytic      bolus      ode
# 5 analytic   infusion      ode
# 6 analytic firstOrder      ode

# analytic-bolus & analytic           : analytic          & analytic                 : PKPD analytic
# analytic-infusion & analytic        : analytic-infusion & analytic                 : PKPD analytic infusion
# analytic-firstOrder & analytic      : analytic          & analytic                 : PKPD analytic
# analytic-bolus & ode                : analytic          & ODE                      : PKPD ODE dose in equations
# analytic-infusion   & ode           : analytic-infusion & ODE                      : PKPD ODE infusion dose in equations
# analytic firstOrder & ode           : analytic          & ODE                      : PKPD ODE dose in equations

# --------------------------------------
# model parameters
# --------------------------------------

modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.6, omega = sqrt(0.7) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.13, omega = sqrt(0.06) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ) ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ) )

# --------------------------------------
# PK analytic
# PD analytic
# PKPD analytic
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  outcomes = list( "RespPK", "RespPD" ),

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "ImmediateDrugLinear_S0Alin") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK", "newRespPD" ),

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "ImmediateDrugLinear_S0Alin") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK infusion analytic
# PD analytic
# PKPD infusion analytic
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  outcomes = list( "RespPK", "RespPD" ),

  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV",
                          "PDModel" = "ImmediateDrugLinear_S0Alin") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK", "newRespD" ),

  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV",
                          "PDModel" = "ImmediateDrugLinear_S0Alin") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK analytic
# PD ODE
# PKPD ODE dose in equations
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "TurnoverRinFullImax_RinCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK" = "newC1",
                   "newRespD" = "newC2" ),

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV",
                          "PDModel" = "TurnoverRinFullImax_RinCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# -------------------------------------------
# PK infusion analytic
# PD ODE
# PKPD ODE infusion dose in equations
# -------------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list("newRespPK" = "newC1",
                  "newRespD" = "newC2"),

  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )
























