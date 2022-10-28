classdef (ConstructOnLoad = true) HazardObject < handle
    properties
        side
        position
        offset
        vertex
        faces
        normals
        name
        mesh
        active
    end
    methods
        function self = HazardObject()
            self.side = 0.5;
            self.position = transl([5 -1.2 0]);
            self.offset = [0 0 1];
            plotOptions.plotFaces = false;
            [vertex,faces,faceNormals] = RectangularPrism(self.position(1:3,4)'-self.side/2, self.position(1:3,4)'+self.side/2,plotOptions);
            self.vertex = vertex+self.offset; self.faces = faces; self.normals = faceNormals;
            self.name = 'HUMAN BODY.ply';
            self.mesh = self.drawObject();
        end
        function obj = drawObject(self)
            [f,v,data] = plyread(self.name, 'tri');
            vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue]/256;
            mesh_h = trisurf(f,v(:,1),v(:,2),v(:,3) ...
                , 'FaceVertexCData', vertexColours, 'EdgeColor','interp','EdgeLighting','Flat');
            mesh_h.Vertices = self.transform(mesh_h.Vertices,self.position*trotz(270,'deg'));
            obj = mesh_h;
        end
        function newVerts = transform(self,verts,pose)
            UpdatedPoints = [pose * [verts,ones(size(verts,1),1)]']';
            newVerts = UpdatedPoints(:,1:3);
        end
        function move(self,pose)
            self.position = self.position*pose;
            self.vertex = self.vertex + transl(pose)';
            self.mesh.Vertices = self.transform(self.mesh.Vertices,pose);
            drawnow();
        end
    end
end