classdef OCLib_Pipe < ODESCA_Component
    % DESCRIPTION
    %   To model the transport process through a pipe, it can be devided
    %   into an arbitrary number of Nodes. The Nodes are numbered in
    %   ascending order in direction of the massflow.
    %       -----------------------
    %   --> | 1 | 2 | 3 | ... | n | -->
    %       -----------------------
    %
    % PROPERTIES:
    %
    % CONSTRUCTOR:
    %   obj = OCLib_Water_Pipe()
    %
    % METHODS:
    %
    % LISTENERS:
    %
    % NOTE:
    %   - It is possible to have components without states, inputs or
    %     without parameters.
    %   - Every component has to have at least one output.
    %
    % SEE ALSO
    %
    
    % FILE
    %
    % USED FILES
    %
    % AUTHOR
    %    T. Grunert
    %
    % CREATED
    %    2016-Mai-10
    %
    % VERSION CONTROL
    %    $Rev:
    %    $Date:
    %    $Author:
    
    properties
    end
    
    methods
        function obj = OCLib_Pipe(name)
            % Constructor of the component
            %
            % SYNTAX
            %   obj = OCLib_Water_Pipe();
            %
            % INPUT ARGUMENTS
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj: new instance of the class
            %
            % DESCRIPTION
            %   In the constructor the construction parameters needed for
            %   the calculation of the equations has to be specified.
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Set the name if a name was given
            if( nargin == 1 )
                obj.setName(name);
            end
            
            % ---- Instruction ----
            % Define the construction parameters which are needed for the
            % creation of the equations by filling in the names of the
            % construction parameters in the array below. If you don't want
            % to have construction parameters just leave the array empty.
            %
            % NOTE: To access the construction parameter in the sections
            % below use the command:
            %       obj.constructionParam.PARAMETERNAME
            %==============================================================
            %% DEFINITION OF CONSTRUCTION PARAMETERS (User editable)
            %==============================================================          
            
            constructionParamNames = {'Nodes'};
            
            %==============================================================
            %% Template Code
            obj.addConstructionParameter(constructionParamNames);
            if(isempty(constructionParamNames))
                obj.tryCalculateEquations();
            end 
        end
    end
    
    methods(Access = protected)
        function calculateEquations(obj)
            % Calculates the equations of the component
            %
            % SYNTAX
            %
            % INPUT ARGUMENTS
            %   obj:    Instance of the object where the method was
            %           called. This parameter is given automatically.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %
            % DESCRIPTION
            %   In this method the states, inputs, outputs and parameters
            %   are defined and the equations of the component are
            %   calculated.
            %
            % NOTE
            %   - This method is called by the method
            %     tryCalculateEquations() to avoid a call if not all
            %     construction parameters are set.
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % ---- Instruction ----
            % Define the states, inputs, outputs and parameters in the
            % arrays below by filling in their names as strings. If you
            % don't want states, inputs or parameters, just leave the array
            % empty. It is not possible to create a component without
            % outputs. 
            % The corresponding arrays contain the unit strings for the 
            % states, inputs, outputs and parameters. These arrays must 
            % have the same size as the name arrays!
            %==============================================================
            %% DEFINITION OF EQUATION COMPONENTS (User editable)
            %==============================================================
            
            stateNames  = cellstr('');
            stateUnits  = cellstr('');
            for k = 1:obj.constructionParam.Nodes
                
               stateNames{k, 1} = ['Temp', num2str(k)];
               stateUnits{k, 1} = '�C';
               
            end
            
            inputNames  = {'TempIn', 'mDotIn'};
            inputUnits  = {'�C', 'kg/s'};
            
            outputNames = {'TempOut', 'mDotOut'};
            outputUnits = {'�C', 'kg/s'};
            
            paramNames  = {'cPipe', 'mPipe', 'VPipe', 'RhoFluid', 'cFluid'};
            paramUnits  = {'J/kg*K', 'kg', 'm^3', 'kg/m^3', 'J/kg*K'};
            
            % =============================================================
            %% Template Code
            obj.initializeBasics(stateNames, inputNames, outputNames,...
                paramNames, stateUnits, inputUnits, outputUnits, paramUnits);
            obj.prepareCreationOfEquations();
            %
            %
            % ---- Instruction ----
            % Use 'obj.f(NUM)' for the state equations and 'obj.g(NUM) for 
            % the output equations e.g. obj.f(1) = ... to access state x1
            %
            % All parameters, states and inputs are in the function
            % workspace so if e.g. a paramter with the name 'radius' is
            % defined you can use the variable 'radius' without further
            % definition. You can also access the states by 'obj.x(NUM)', 
            % the inputs by 'obj.u(NUM)' and the parameter in the order
            % of the list paramNames by using 'obj.p(NUM)' where NUM
            % is the position.
            % Note that every component must have at least one output.
            %==============================================================
            %% DEFINITION OF EQUATIONS (User Editable)
            %==============================================================
             
            Nodes = obj.constructionParam.Nodes;
            VolumeNode = VPipe/Nodes;
            CFluidNode = RhoFluid * cFluid * VolumeNode;
            CPipeNode = cPipe * mPipe / Nodes;
            
            for i = 1:Nodes
                if i == 1
                    HeatTransport = mDotIn * cFluid * (TempIn - obj.x(i));                     
                else
                    HeatTransport = mDotIn * cFluid * (obj.x(i - 1) - obj.x(i));   
                end                    
                obj.f(i) = (HeatTransport) / (CPipeNode + CFluidNode);
            end
            
            obj.g(1) = obj.x(Nodes);
            obj.g(2) = mDotIn;
            
            %==============================================================
        end
    end
end