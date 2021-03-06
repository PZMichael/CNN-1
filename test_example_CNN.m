
close;
%clear;


rng(4);
j=1;
for patient = 100 :234

    if patient==100 || patient==103 || patient==105 || patient==111 || patient==113 ...
        || patient==117 || patient==121 || patient==123 || patient==200 || patient==202 ...
        || patient==210 || patient==212 || patient==213 || patient==214 || patient==219 ...
        || patient==221 || patient==222 || patient==228 || patient==231 || patient==232 ...
        || patient==233 || patient==234 
        file_name=['C:\Users\victo\Desktop\git_home\individual_data\balanced',num2str(patient),'.mat'];
        load(file_name);

        cnn.layers = {
            struct('type', 'i') %input layer
            struct('type', 'c', 'outputmaps', 2, 'kernelsize', 8) %outputmaps 2 for efficiency, kernelsize 7,11,15,19..., some kernelsize may not work due to rand() generator setting
            %struct('type', 'c', 'outputmaps', 18, 'kernelsize', 7)  %for ecg, convolution layer
            %struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %for n by n image, convolution layer
            struct('type', 's', 'scale', 2) %subsampling layer

            struct('type', 'c', 'outputmaps', 2, 'kernelsize', 8) %feature map size reduced to 2 to reduce computation time, should not affect error much for ecg
            %struct('type', 'c', 'outputmaps', 18, 'kernelsize', 7) %for ecg, convolution layer
            %struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %for n by n image, convolution layer
            struct('type', 's', 'scale', 2) %subsampling layer

            struct('type', 'c', 'outputmaps', 2, 'kernelsize', 7) %feature map size reduced to 2 to reduce computation time, should not affect error much for ecg
            %struct('type', 'c', 'outputmaps', 18, 'kernelsize', 7) %for ecg, convolution layer
            %struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %for n by n image, convolution layer
            struct('type', 's', 'scale', 2) %subsampling layer

            };

        opts.alpha = 0.1;
        opts.batchsize = 30;
        opts.numepochs = 2;
        opts.a = 1;
        opts.c = 1;
        train_x = otraining_data(1:301,:);
        train_y = otraining_data(324:328,:);
        test_x = overification_data(1:301,:);
        test_y = overification_data(324:328,:);

        for i = 1: length(train_x)
            train_x(:,i) = train_x(:,i) - min(train_x(:,i));
            train_x(:,i) = train_x(:,i) / max(train_x(:,i));
        end
        for i = 1: length(test_x)
            test_x(:,i) = test_x(:,i) - min(test_x(:,i));
            test_x(:,i) = test_x(:,i) / max(test_x(:,i));
        end

        %train_x(302:323,:) = otraining_data(302:323,:);
        %test_x(302:323,:) = overification_data(302:323,:);

        cnn = cnnsetup(cnn, train_x, train_y);
        [net, ematrix, result_verification] = cnntrain(cnn, train_x, train_y, opts, test_x, test_y);

        eval(['result_matrix{' num2str(j) '}{1,1} = result_verification' ]);
        eval(['result_matrix{' num2str(j) '}{1,2} = ematrix' ]);
        highest_accuracy =  find(result_matrix{1,1}{1,1}(1,:) == max(result_matrix{1,1}{1,1}(1,:)), 1, 'last');
        highest_sensitivity = find(result_matrix{1,1}{1,1}(2,:) == max(result_matrix{1,1}{1,1}(2,:)), 1, 'last');
        highest_predictivity = find(result_matrix{1,1}{1,1}(3,:) == max(result_matrix{1,1}{1,1}(3,:)), 1, 'last');
        lowest_false_positive = find(result_matrix{1,1}{1,1}(4,:) == min(result_matrix{1,1}{1,1}(4,:)), 1, 'last');
        a_s_p_f = [highest_accuracy highest_sensitivity highest_predictivity lowest_false_positive];
        eval(['result_matrix{' num2str(j) '}{2,1} = a_s_p_f' ]);
     
        j=j+1;
        
        %figure;
        %plot(error_plot);
        %title('Error Plot');
    end
end

clear i j net opts otraining_data overification_data patient result_verification test_x ...
    test_y train_x train_y a_s_p_f cnn dtraining_data dverification_data ematrix file_name ...
    traing_y highest_sensitivity highest_accuracy highest_predictivity lowest_false_positive 
    
