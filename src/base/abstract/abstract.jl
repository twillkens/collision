export Entity, Domain, Atom
export Aspect, Phenotype, Genotype, Organism
export Population, Domain, Recipe, Mix
export Outcome, Statistics, Coevolution

# top level
abstract type Entity end

# entity that cannot be composed into subentities
abstract type Atom <: Entity end

abstract type Aspect end

# datatype of the "DNA" or information for encoding an entity
abstract type Genotype <: Aspect end

# datatype of the "expression" of the genotype, used for evaluation
abstract type Phenotype <: Aspect end

# atomic entity comprising a genotype and a phenotype
abstract type Organism{G <: Genotype, P <: Phenotype} <: Atom end

# a set of organisms (which itself constitutes an entity)
abstract type Population{O <: Organism} <: Entity end

# a mode of interaction between entities
abstract type Domain end

# a means of determining which entities interact 
abstract type Recipe end

# specifies (1) a set of entities or their keys, (2) the domain in which they interact
abstract type Mix{T, D <: Domain} end

# an outcome of an interaction
abstract type Outcome end

# statistics associated with an entity
abstract type Statistics end

# driver
abstract type Coevolution <: Entity end
