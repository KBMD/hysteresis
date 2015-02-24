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
     C                   Gij)

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
        Integer        NoOfPoly
        Parameter     (NoOfPoly=3)
        Integer        CurEntry
        Integer        PolyNum
        Real (Kind=8)  MaxAbscissa

        MaxAbscissa = Abscissa(1,TotalDataValues)
		
        Do CurEntry = 1, TotalDataValues
           Gij(1,CurEntry,1) = 1D0
           Gij(1,CurEntry,2) = Abscissa(1,CurEntry)
           Gij(1,CurEntry,3) = Abscissa(1,CurEntry)**2
        EndDo

        Return
        End
