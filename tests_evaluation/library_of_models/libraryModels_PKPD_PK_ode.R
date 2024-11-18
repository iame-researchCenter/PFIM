######################################################

# PKPD
# PK : ODE

######################################################

modelPKType = c("ode")
modelPKAdmin = c("bolus","infusion","firstOrder")
modelPDType = c("analytic","ode")
expand.grid(modelPKType, modelPKAdmin,modelPDType)


# 1  ode      bolus analytic
# 2  ode   infusion analytic
# 3  ode firstOrder analytic
# 4  ode      bolus      ode
# 5  ode   infusion      ode
# 6  ode firstOrder      ode

# ode-bolus      & ode           : ode dose not in equations       & ODE                      : PKPD ode bolus
# ode-infusion   & ode           : ode infusion dose in equations  & ODE                      : PKPD ode infusion dose in equations
# ode-firstOrder & ode           : ode dose in equations           & ODE                      : PKPD ODE ode dose in equations

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
# PK ode-bolus
# PD ode
# PK ode-bolus
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "MichaelisMenten1BolusSingleDose_VmKm",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )


# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK" = "newC1",
                   "newRespD" = "newC2" ),

  modelFromLibrary = list("PKModel" = "MichaelisMenten1BolusSingleDose_VmKm",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK ode infusion dose in equations
# PD ode
# PKPD ode infusion dose in equations
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "MichaelisMenten2InfusionSingleDose_VmKmk12k21V1V2",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK1" = "newC1",
                   "newRespPK2" = "newC2",
                   "newRespD" = "newE" ),

  modelFromLibrary = list("PKModel" = "MichaelisMenten2InfusionSingleDose_VmKmk12k21V1V2",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK ode dose in equations
# PD ode
# PKPD ode dose in equations
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "MichaelisMenten2FirstOrderSingleDose_kaVmKmk12k21V1V2",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )


# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list("newRespPK1" = "newC1",
                  "newRespPK2" = "newC2",
                  "newRespD" = "newC3"),

  modelFromLibrary = list("PKModel" = "MichaelisMenten2FirstOrderSingleDose_kaVmKmk12k21V1V2",
                          "PDModel" = "TurnoverRinEmax_RinEmaxCC50koutE") )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )
