classdef (Sealed) BaseFunctions < handle
	methods (Access = private)
		function obj = BaseFunctions
			s = RandStream('mt19937ar','Seed','shuffle');
			RandStream.setGlobalStream(s);
		end
	end
	methods (Static)
		function singleObj = getInstance
			persistent localObj
			if isempty(localObj) || ~isvalid(localObj)
				localObj = BaseFunctions;
			end
			singleObj = localObj;
		end

		% This is a very simplistic implementation of our stress protocol;
		% We expect as input a .mat file with a variable named "feature_vector". Such feature vectors can extracted with anything you like (deep model, bag-of-visual-words etc.);
		% To use our transformations with another input format, you just have to reimplement the functions below.

		function [feat_matrix, files]=load_folder(folder_path, single_file)
			% Load all files containing feature vectors inside a folder.
			% 
			% folder_path = Path to the folder containing the feature vectors;
			% single_file = Should we load only one file to count the dimensions? 1 or 0 (default).

			if ~exist('single_file', 'var'), single_file = 0; end
			files = dir(folder_path);
			files = {files(~[files.isdir]).name};
			files = regexp(files, '(\w*.mat$)', 'match');
			files = [files{:}];
			feat_matrix = [];
			nfiles = numel(files);
			if(single_file == 1)
				nfiles = 1;
			end
			for nfile = 1:nfiles
				fprintf('Loading file %d/%d...\n', nfile, nfiles);
				feat = BaseFunctions.getInstance.load_file(sprintf('%s/%s', folder_path, char(files(nfile))));
				if nfile > 1
					if numel(feat) ~= feat_size
						throw(MException('common:load_folder', sprintf('ERROR: Feature vector size mismatch.\n>> All feature vectors must have the same size.\n>> Cause: %s vs %s.', char(files(nfile-1)), char(files(nfile)))));
					end
				else
					feat_size = numel(feat);
				end
				feat_matrix = [feat_matrix; feat];
			end
			fprintf('Finished loading %d files.\n', nfiles);
		end

		function [feat_matrix]=load_image_batch(folder_path, image_list, position, total)
			% Load all files containing feature vectors inside a folder.
			% 
			% folder_path = Path to the folder containing the feature vectors;
			% image_list = List of images to load from folder_path;
			% position = Used to display the counter, shows the number of the current file being loaded;
			% total = Used to display the counter, shows the total number of files to load.

			feat_matrix = [];
			nfiles = numel(image_list);
			for nfile = 1:nfiles
				fprintf('Loading file %d/%d: %s\n', position + nfile, total, char(image_list(nfile)));
				feat = BaseFunctions.getInstance.load_file(sprintf('%s/%s', folder_path, char(image_list(nfile))));
				if nfile > 1
					if numel(feat) ~= feat_size
						throw(MException('common:load_folder', sprintf('ERROR: Feature vector size mismatch.\n>> All feature vectors must have the same size.\n>> Cause: %s vs %s.', char(files(nfile-1)), char(files(nfile)))));
					end
				else
					feat_size = numel(feat);
				end
				feat_matrix = [feat_matrix; feat];
			end
			if nfile == total
				fprintf('Finished loading %d files.\n', nfiles);
			end
		end

		function [folder_path, image_list]=get_image_list(file_or_folder)
			% Load the name of all files containing feature vectors inside a folder.
			% 
			% folder_path = Path to the folder containing the feature vectors.

			if isdir(file_or_folder)
				if ~exist('single_file', 'var'), single_file = 0; end
				files = dir(file_or_folder);
				files = {files(~[files.isdir]).name};
				files = regexp(files, '(\w*.mat$)', 'match');
				image_list = [files{:}];
				folder_path = file_or_folder;
			else
				[folder_path, image_name, image_extension] = fileparts(file_or_folder);
				image_list = [sprintf('%s%s', image_name, image_extension)];
			end
		end

		function [feature_vector]=load_file(full_filename)
			% Load a file containing feature vectors inside.
			% 
			% full_filename = Full path to the file containing the feature vectors.

			fobj = matfile(full_filename);
			if getnameidx(who(fobj), 'feature_vector')
				feature_vector = fobj.feature_vector;
			else
				throw(MException('common:load_file', sprintf('ERROR: File %s is not a valid descriptor (field feature_vector not found).', full_filename)));
			end
		end

		function save_feature_vector(feature_vector, full_filename)
			% Save a feature vector to a .mat file.
			% 
			% feature_vector = A feature vector with (1,n) dimensions;
			% full_filename = Full path to the file containing the feature vectors.

			save(full_filename, 'feature_vector');
		end
	end
end
