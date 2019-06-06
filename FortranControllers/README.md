ls# Fortan Controllers

This contains various Fortran controllers that have been developed. 

## Current Controllers
NREL_Baseline
	- This controller has the basic NREL 5MW Turbine controller logic, with some slight modifications. The Sowento setpoint smoother has been added, with a flag. This will eventually be developed such that it incoorporates an input file. 

NREL_5MW
	- This is truly the NREL 5MW Baseline controllers, as published for the NREL 5MW wind turbine models distributed as a part of the openfast archives. An additional shutdown controller has also been added to these
