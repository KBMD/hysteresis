         Subroutine Model(CurSet,
     C                   NoOfParams,
     C                   NoOfDerived,
     C                   TotalDataValues,
     C                   MaxNoOfDataValues,
     C                   NoOfDataCols,
     C                   NoOfAbscissaCols,
     C                   NoOfModelVectors,
     C                   Params,
     C                   Derived,
     C                   Abscissa,
     C                   Signal)

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
        Real (Kind=8), Intent(InOut)::Signal(NoOfDataCols,MaxNoOfDataValues)
        Integer        NoOfDoses
        Parameter     (NoOfDoses=4)
        Integer        N
        Parameter     (N=1)
        Real (Kind=8)  D(NoOfDoses)
        Data           D/1.0,1.0,1.0,1.0/
        Real (Kind=8)  TimeOfDose(NoOfDoses)
        Data           TimeOfDose/15.0,19.0,23.0,27.0/
        Real (Kind=8)  tHalf
        Integer        CurEntry
        Integer        CurDose
        Real (Kind=8)  EC50,TS,C,U,T,Emax,QuadAmp,LinAmp,Constant

        EC50  = Params(1)
        TS    = Params(2)
        tHalf = Params(3)
        Emax  = Params(4)
        QuadAmp = Params(7)
        LinAmp = Params(6)
        Constant = Params(5)

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
           Signal(1,CurEntry) = Emax*(C**N/(EC50 + C**N)) + QuadAmp*(Abscissa(1,CurEntry)**2) + LinAmp*Abscissa(1,CurEntry)
     C + Constant
        EndDo

        Derived(1)=EC50
        Derived(2)=TS
        Derived(3)=tHalf
        Derived(4)=Emax

        Return
        End
