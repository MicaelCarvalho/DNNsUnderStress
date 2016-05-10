function []=describe(image_or_folder, output_folder)
    % image_or_folder = path to a folder containing images or to a single image;
    % output_folder = path to a folder; we will save the features there.

    if ~exist('image_or_folder', 'var')
    	throw(MException('extra:image_or_folder', 'ERROR: Parameter image_or_folder is empty.'));
    end
    if ~exist('output_folder', 'var')
    	throw(MException('extra:output_folder', 'ERROR: Parameter output_folder is empty.'));
    end

    addpath('..');
    fcommon = BaseFunctions.getInstance;

	if ~exist('matconvnet-1.0-beta18', 'dir')
		untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta18.tar.gz');
		cd matconvnet-1.0-beta18;
		run matlab/vl_compilenn;
		cd ..;
	end
	
	if ~exist('imagenet-vgg-m.mat', 'file')
		urlwrite('http://www.vlfeat.org/matconvnet/models/imagenet-vgg-m.mat', 'imagenet-vgg-m.mat') ;
	end

	fprintf('Starting MatConvNet...\n');
	
	cd matconvnet-1.0-beta18;
	run matlab/vl_setupnn
	cd ..;

	fprintf('Loading VGG-M...\n');
	net = load('imagenet-vgg-m.mat');

	nfiles = 0;
	if isdir(image_or_folder)
        files = dir(image_or_folder);
		files = {files(~[files.isdir]).name};
		for file = files
			nfiles = nfiles + 1;
			fprintf('Describing ''%s''...\n', char(file));
			try
				im = imread(sprintf('%s/%s', image_or_folder, char(file)));
			catch exception
				fprintf('!!!!! WARNING: Impossible to open ''%s'', file ignored.\n', char(file));
				continue;
			end
			im_ = single(im);
			im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
			im_ = im_ - net.meta.normalization.averageImage;
	        res = vl_simplenn(net, im_);
	        raw = res(19+1).x;
	        val = squeeze(double(raw));
			no = norm(val);
			feature_vector = squeeze(raw ./ no)';
			[ign, file, ext] = fileparts(char(file));
			fcommon.save_feature_vector(feature_vector, sprintf('%s/%s', output_folder, char(file)));
		end
    else
    	nfiles = 1;
    	[ign, file, ext] = fileparts(image_or_folder);
    	files = sprintf('%s.%s', char(file), char(ext));
		fprintf('Describing ''%s''...\n', file);
		im = imread(image_or_folder);
		im_ = single(im);
		im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
		im_ = im_ - net.meta.normalization.averageImage;
        res = vl_simplenn(net, im_);
        raw = res(19+1).x;
        val = squeeze(double(raw));
		no = norm(val);
		feature_vector = squeeze(raw ./ no)';
		fcommon.save_feature_vector(feature_vector, sprintf('%s/%s', output_folder, char(file)));
    end
    fprintf('Done processing %d files.\n\n', nfiles);
end
