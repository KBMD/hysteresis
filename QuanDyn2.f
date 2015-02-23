         Subroutine Model(CurSet,          ! If there are N data sets, CurSet ranges from 1 to N
     C                   NoOfParams,       ! The number of nonamplitude priors given in the .params file
     C                   NoOfDerived,      ! The number of derived parameters specified in the .params file
     C                   TotalDataValues,  ! The number of hyper-complex data values in the current set
     C                   MaxNoOfDataValues,! The largest number of data values in all input sets
     C                   NoOfDataCols,     ! The number of data column specified in the .params file
     C                   NoOfAbscissaCols, ! The number of abscissa columns specified in the .params file
     C                   NoOfModelVectors, ! The number of output model vectors specified in the .params file
     C                   Params,           ! The parameters for which the model must be evaluated
     C                   Derived,          ! The output derived parameters
     C                   Abscissa,         ! The abscissa values at which the model must be evaluated
     C                   Gij)              ! The output model vectors
!----------------------------------------------------------------------------------------------------------
!  QuanDyn2.f   The QuanDyn model is used to gather pharmacodynamic (PD) information from a single fMRI    |
!               scanning session. It is a modified version of the Hill equation (also called the Emax      |
!               model). The independent variable is time, and the dependent variable is fMRI signal.       |
!               This version of the model contains a quadratic trend in the data.                          |
!                                                                                                          |
!  Number of priors in QuanDyn2.params: 7                                                                  |
!  Number of model vectors:             4                                                                  |
!  Number of derived parameters:        0                                                                  |
!  Number of data columns:              1                                                                  |
!                                                                                                          |
!  Ascii File Input: Two columns of the form (time data) having at least 8 data values                     |
!                                                                                                          |
!  Fid Image File: One arrayed variable having at least 8 arrayed elements.                                |
!                                                                                                          |
!  Abscissa File: Single column file containing the time values, only needed when you                      |
!    manually load 4dfp files or when the abscissa was not correctly generated from procpar.               |
!                                                                                                          |
!  Parameters: EC50, TS, tHalf, Amplitude, Constant, LinearAmplitude and a QuadAmp                         |
!                                                                                                          |
!  QuanDyn2.params defines a single nonlinear parameter:                                                   |
!     Param#      Name         Description                                                                 |
!       1         EC50         EC50 is the input concentration at which the effect is 0.5*Emax.            |
!       2         TS           The time shift in the arrival time of the dose                              |
!       3         tHalf        The half-life of a dose                                                     |
!                                                                                                          |
!  QuanDyn2.params defines three amplitudes, Amplitude, Constant, and LinearAplitude which are marginalized|
!     Amplitude#  Name        Description                                                                  |
!         1       Emax        The maximal effect that can be reached by the curve.                         |
!         2       Constant    A constant offset in the data.                                               |
!         3       LinearAmp   A linear trend in the data.                                                  |
!         4       QuadAmp     A quadratic trend in the data.                                               |
!                                                                                                          |
!  QuanDyn2.params has no derived parameters.                                                              |
!----------------------------------------------------------------------------------------------------------
        Implicit  None
        Integer,       Intent(In)::   CurSet
        Integer,       Intent(In)::   NoOfParams
        Integer,       Intent(In)::   NoOfDerived
        Integer,       Intent(In)::   TotalDataValues
        Integer,       Intent(In)::   MaxNoOfDataValues
        Integer,       Intent(In)::   NoOfDataCols
        Integer,       Intent(In)::   NoOfAbscissaCols
        Integer,       Intent(In)::   NoOfModelVectors
        Real (Kind=8), Intent(In)::   Params(NoOfParams)
        Real (Kind=8), Intent(InOut)::Derived(NoOfDerived)
        Real (Kind=8), Intent(In)::   Abscissa(NoOfAbscissaCols,MaxNoOfDataValues)
        Real (Kind=8), Intent(InOut)::Gij(NoOfDataCols,MaxNoOfDataValues,NoOfModelVectors)
        Integer        NoOfDoses
        Parameter     (NoOfDoses=4)
        Integer        N
        Parameter     (N=1)
        Real (Kind=8)  D(NoOfDoses)
        Data           D/1.0,1.0,1.0,1.0/
        Real (Kind=8)  TimeOfDose(NoOfDoses)
        Data           TimeOfDose/8.0,16.0,24.0,32.0/
        Real (Kind=8)  tHalf
        Integer        CurEntry
        Integer        CurDose
        Real (Kind=8)  EC50,TS,C,U,T
        Character (Len=3)Error

        Ec50  = Params(1)
        TS    = Params(2)
        tHalf = Params(3)

        Error = 'Yes'
        Do CurEntry = 1, TotalDataValues
           C = 0D0
           Do CurDose = 1, NoOfDoses
              T = Abscissa(1,CurEntry) - TS - TimeOfDose(CurDose)
              If(T.Lt.0D0)Then
                 U = 0D0
              Else
                 U = 1D0
              EndIf
              C = C + D(CurDose)*((0.5D0)**(T/tHalf))*U
           EndDo
           Gij(1,CurEntry,1) = C**n/(Ec50 + C**n)
           Gij(1,CurEntry,2) = 1D0
           Gij(1,CurEntry,3) = Abscissa(1,CurEntry)
           Gij(1,CurEntry,4) = Abscissa(1,CurEntry)**2

           If(Gij(1,CurEntry,1).Ne.0D0)Then
              Error = 'No'
           EndIf
        EndDo
        If(Error.Eq.'Yes')Then
           Gij(1,1,1) = 1D0
        EndIf

        Return
        End
