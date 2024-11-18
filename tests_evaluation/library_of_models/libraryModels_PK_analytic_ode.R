# model parameters
modelParameters = list(
  ModelParameter( name = "ka", distribution = LogNormal( mu = 1.6, omega = sqrt(0.7) ) ),
  ModelParameter( name = "V",  distribution = LogNormal( mu = 8, omega = sqrt(0.02) ) ),
  ModelParameter( name = "Cl", distribution = LogNormal( mu = 0.13, omega = sqrt(0.06) ) ),
  ModelParameter( name = "Rin", distribution = LogNormal( mu = 5.4, omega = sqrt(0.2) ) ),
  ModelParameter( name = "kout",distribution = LogNormal( mu = 0.06, omega = sqrt(0.02) ) ),
  ModelParameter( name = "C50",distribution = LogNormal( mu = 1.2, omega = sqrt(0.01) ) ) )

# --------------------------------------
# PK analytic
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV" ) )

model = defineModel( model )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list("newRespPK"),

  modelFromLibrary = list("PKModel" = "Linear1FirstOrderSingleDose_kaClV" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK analytic infusion
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list("newRespPK"),

  modelFromLibrary = list("PKModel" = "Linear1InfusionSingleDose_ClV" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK ode dose in equation
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "MichaelisMenten2FirstOrderSingleDose_kaVmKmk12k21V1V2" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK1" = "newC1",
                   "newRespPK2" = "newC2" ),

  modelFromLibrary = list("PKModel" = "MichaelisMenten2FirstOrderSingleDose_kaVmKmk12k21V1V2" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK ode bolus
# --------------------------------------

# by default
model = Model(

  parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "MichaelisMenten1BolusSingleDose_VmKm" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list("newRespPK" = "newC1"),
  modelFromLibrary = list("PKModel" = "MichaelisMenten1BolusSingleDose_VmKm" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# --------------------------------------
# PK ode infusion dose in equations
# --------------------------------------

# by default
model = Model(

 parameters = modelParameters,

  modelFromLibrary = list("PKModel" = "MichaelisMenten2InfusionSingleDose_VmKmk12k21V1V2" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )

# user outcomes
model = Model(

  parameters = modelParameters,

  outcomes = list( "newRespPK1" = "newC1",
                   "newRespPK2" = "newC2" ),

  modelFromLibrary = list("PKModel" = "MichaelisMenten2InfusionSingleDose_VmKmk12k21V1V2" ) )

model = defineModel( model, Design() )

print( model@equations )
print( model@outcomes )














