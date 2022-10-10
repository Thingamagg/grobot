classdef (ConstructOnLoad = true) GroceryObject < handle
    properties
        pose
        spherex
        spherey
        spherez
        name
        model
        scale
    end
    methods
        function obj = GroceryObject(pose)
            obj.pose = pose
            obj.name = 'Grocery'
            [obj.spherex,obj.spherey,obj.spherez] = sphere(10)
            obj.model = obj.GetModel()
            obj.scale = 0.1
        end
        function print(obj)
            xyzpose = transl(obj.pose)
            surf(obj.spherex*0.5 + xyzpose(1), obj.spherey*0.5 + xyzpose(2), obj.spherez*0.5 + xyzpose(3))
        end
        
        function model = GetModel(obj)
            
            [faceData,vertexData] = plyread('cube.ply','tri');
            L1 = Link('alpha',-pi/2,'a',0,'d',0.3,'offset',0);
            model = SerialLink(L1,'name',obj.name);
            model.faces = {faceData,[]};
            vertexData(:,2) = vertexData(:,2) + 0.4;
            model.points = {vertexData * rotx(-pi/2),[]};
        end
        
        function plot(obj,workspace)
            plot3d(obj.model,0,'workspace',workspace,'scale',obj.scale);%,0,'workspace',workspace,'view',[-30,30]);
        end
        
        function animate(obj)
            obj.model.base = obj.pose
            animate(obj.model,0)
        end
    end
end