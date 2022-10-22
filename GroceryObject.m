classdef (ConstructOnLoad = true) GroceryObject < handle
    properties
        count = 1
        object
        shelfsize = [3,3]
        workspace
    end
    methods
        function self = GroceryObject(count,workspace)
            if 0 < nargin
                self.count = count;
            end
            %obj.pose = pose
            %obj.name = 'Grocery'
            %[obj.spherex,obj.spherey,obj.spherez] = sphere(10)
            %obj.model = obj.GetModel()
            %obj.scale = 0.1
            coords = self.getRandomShelfLocations();
            self.workspace = workspace;
            for i = 1:self.count
                self.object{i} = self.initSingleGroceryObject(i);
                self.object{i}.base = transl(coords(i,:));
                self.plot(self.object{i},self.workspace);
            end
            
        end
        
        function object = initSingleGroceryObject(self,identifier)
            object = self.GetCylinder(identifier);
        end
        
        function coords = getRandomShelfLocations(self)
            basez = 0.35;
            dimensions = [-0.4 -0.5 0.3];
            slots = [8 3]; slots(1) = max(slots(1),self.count);
            coords = [randperm(slots(1),self.count)*dimensions(1); dimensions(2)*ones(1,self.count);(randi(slots(2),1,self.count)*dimensions(3))+basez]';
        end
        
        function model = GetCylinder(obj,identifier)
            [faceData,vertexData] = plyread('cylinder.ply','tri');
            L1 = Link('alpha',-pi/2,'a',0,'d',0.3,'offset',0);
            model = SerialLink(L1,'name',['grocery',num2str(identifier)]);
            model.faces = {faceData,[]};
            vertexData(:,2) = vertexData(:,2) + 0.4;
            model.points = {vertexData * rotx(-pi/2),[]};
        end
        
        function plot(self,obj,workspace)
            plot3d(obj,0,'workspace',workspace);%,0,'workspace',workspace,'view',[-30,30]);
        end
        
        function animate(self)
            %obj.model.base = obj.pose;
            for i = 1:self.count
                %self.object{i}.animate(0);
                animate(self.object{i},0);
            end
            drawnow();
        end
    end
end