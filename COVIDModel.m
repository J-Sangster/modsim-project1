classdef COVIDModel
    %MAIN SEIRVD Model with ONLY two interacting subpopulations
    % Besides elementary stock/flow equations, the behavior is as noted:
    % Subpopulation delta for stocks are computed independently of each
    % other
    % An additional delta representing interacting subpopulations is
    % computed
    % The total deltas are then added to the original stocks

    properties
        subpopulation1
        subpopulation2
        
        PInfect1Semirisk2
        PInfect1Risk2
        PInfect2Semirisk1
        PInfect2Risk1
    end

    methods
        function obj = COVIDModel(subpopulation1,subpopulation2, PInfect1Semirisk2, PInfect1Risk2, PInfect2Semirisk1, PInfect2Risk1)
            %Provide both subpopulations and parameters indicating how 
            %   Detailed explanation goes here
            obj.subpopulation1 = subpopulation1;
            obj.subpopulation2 = subpopulation2;
            obj.PInfect1Semirisk2 = PInfect1Semirisk2;
            obj.PInfect1Risk2 = PInfect1Risk2;
            obj.PInfect2Semirisk1 = PInfect2Semirisk1;
            obj.PInfect2Risk1 = PInfect2Risk1;

            assert(PInfect1Semirisk2 <= PInfect1Risk2, "Risk must be greater than or equal to semirisk");
            assert(PInfect2Semirisk1 <= PInfect2Risk1, "Risk must be greater than or equal to semirisk");
        end

        function simulateAction(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            deltaSemirisk2 = obj.PInfect1Semirisk2*obj.subpopulation1.numInfected*(obj.subpopulation2.numVaccinated+obj.subpopulation2.numPostInfection);
            deltaRisk2 = obj.PInfect1Risk2 * obj.subpopulation1.numInfected * obj.subpopulation2.numNaive;

            deltaSemirisk1 = obj.PInfect2Semirisk1 * obj.subpopulation2.numInfected*(obj.subpopulation1.numVaccinated+obj.subpopulation1.numPostInfection);
            deltaRisk1 = obj.PInfect2Risk1 * obj.subpopulation2.numInfected * obj.subpopulation1.numNaive;
            
            %clamp values, must only do when it takes 3 or more variables.
            deltaSemirisk2 = min(deltaSemirisk2, (obj.subpopulation2.numVaccinated+obj.subpopulation2.numPostInfection));
            deltaSemirisk1 = min(deltaSemirisk1, (obj.subpopulation1.numVaccinated+obj.subpopulation1.numPostInfection));
            
            deltaRisk2 = min(deltaRisk2, obj.subpopulation2.numNaive);
            deltaRisk1 = min(deltaRisk1, obj.subpopulation1.numNaive);

            [postInfection, vaccinated, naive, semirisk, risk, infectious, deceased] = obj.subpopulation1.simulateAction;
            % this is an overestimate, as we also do lose semirisk. we will
            % update if we find total population changes
            max_semirisk = obj.subpopulation1.semirisk + obj.subpopulation1.numVaccinated + obj.subpopulation1.numPostInfection;
            max_risk = obj.subpopulation1.risk + obj.subpopulation1.numNaive;

            semirisk = max(max_semirisk, semirisk + deltaSemirisk1);
            risk = max(max_risk, risk + deltaRisk1);
            
            obj.subpopulation1.setStocks(postInfection, vaccinated, naive, semirisk, risk, infectious, deceased);
            
            [postInfection, vaccinated, naive, semirisk, risk, infectious, deceased] = obj.subpopulation2.simulateAction;
            max_semirisk = obj.subpopulation2.semirisk + obj.subpopulation2.numVaccinated + obj.subpopulation2.numPostInfection;
            max_risk = obj.subpopulation2.risk + obj.subpopulation2.numNaive;

            semirisk = max(max_semirisk, semirisk + deltaSemirisk2);
            risk = max(max_risk, risk + deltaRisk2);

            obj.subpopulation2.setStocks(postInfection, vaccinated, naive, semirisk, risk, infectious, deceased);
        end
    end
end