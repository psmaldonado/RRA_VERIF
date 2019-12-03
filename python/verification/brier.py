def brier_rel_res_uncer(prob_fcst, obs, lenibin):
    """ input:
            prob_fcst  = (nthr,nx,ny)
            obs = (nthr,nx,ny)
        output: brier_rel = (nthr)
    """
    import numpy as np
    bins = np.arange(0,1,lenibin)
    nbins = len(bins)
    thr = prob_fcst.shape[0]
    brier_rel = np.zeros(thr)
    brier_res = np.zeros(thr)
    brier_uncer = np.zeros(thr)
    for ithr in range(thr):
        N = obs[ithr,:,:].count()
        ibrier_rel = 0
        ibrier_res = 0
        o = np.sum(obs[ithr,:,:])
        c = o/N
        fi = 0
        ni = np.sum(prob_fcst[ithr,:,:]==0)
        oij = np.sum((prob_fcst[ithr,:,:]==0) & (obs[ithr,:,:]==1))
        oi = oij/ni
        ci = ni * oi
        ibrier_rel = ni * np.ma.power(fi-oi,2)
        ibrier_res = ni * np.ma.power(oi-c,2)
        ibrier_rel += ibrier_rel
        ibrier_res += ibrier_res
        for ibin in range(nbins):
            low_bin = bins[ibin]
            up_bin = bins[ibin]+lenibin
            ni = np.sum(np.logical_and(prob_fcst[ithr,:,:]<=up_bin, prob_fcst[ithr,:,:]>low_bin).astype(int))
            fij = np.sum(np.ma.masked_where(~((prob_fcst[ithr,:,:]<=up_bin) & (prob_fcst[ithr,:,:]>low_bin)),prob_fcst[ithr,:,:]))
            fi = fij/ni
            oij = np.sum((prob_fcst[ithr,:,:]<=up_bin) & (prob_fcst[ithr,:,:]>low_bin) & (obs[ithr,:,:]==1))
            oi = oij/ni
            ibrier_rel = ni * np.ma.power(fi-oi,2)
            ibrier_res = ni * np.ma.power(oi-c,2)
            ibrier_rel += ibrier_rel
            ibrier_res += ibrier_res
        brier_rel[ithr] = ibrier_rel/N
        brier_res[ithr] = ibrier_res/N
        brier_uncer[ithr] = c*(1-c)
    return brier_rel, brier_res, brier_uncer

def brier_score(prob_fcst,obs):
    """ input:
            prob_fcst  = (nthr,nx,ny)
            obs = (nthr,nx,ny)
        output: brier = (nthr) 
    """
    import numpy.ma as ma
    import math as mt
    import numpy as np
    thr = prob_fcst.shape[0]
    brier = np.zeros(thr)
    for ithr in range(thr):
            SEF = ma.power(obs[ithr,:,:] - prob_fcst[ithr,:,:], 2)
            #print(obs[ithr,:,:])
            #print(prob_fcst[ithr,:,:])
            #print(obs[ithr,:,:] - prob_fcst[ithr,:,:])
            #print(SEF)
            mean = np.ma.mean(SEF)
            brier[ithr] = mt.sqrt(mean)
    return brier

def reliability(prob_fcst,obs,lenibin):
    """ input:
            prob_fcst  = (nthr,nx,ny)
            obs = (nthr,nx,ny)
        output: obs_f = (nthr,nbins+1)
                fcst_f = (nthr,nbins+1)
    """
    import numpy as np
    bins = np.arange(0,1,lenibin)
    nbins = len(bins)
    thr = prob_fcst.shape[0]
    obs_f = np.zeros((thr,nbins+1))
    fcst_f = np.zeros((thr,nbins+1))
    for ithr in range(thr):
        fi = 0
        ni = np.sum(prob_fcst[ithr,:,:]==0)
        oij = np.sum((prob_fcst[ithr,:,:]==0) & (obs[ithr,:,:]==1))
        oi = oij/ni
        obs_f[ithr,0] = oi
        fcst_f[ithr,0] = fi
        for ibin in range(nbins):
            low_bin = bins[ibin]
            up_bin = bins[ibin]+lenibin
            ni = np.sum(np.logical_and(prob_fcst[ithr,:,:]<=up_bin, prob_fcst[ithr,:,:]>low_bin).astype(int))
            fij = np.sum(np.ma.masked_where(~((prob_fcst[ithr,:,:]<=up_bin) & (prob_fcst[ithr,:,:]>low_bin)),prob_fcst[ithr,:,:]))
            fi = fij/ni
            oij = np.sum((prob_fcst[ithr,:,:]<=up_bin) & (prob_fcst[ithr,:,:]>low_bin) & (obs[ithr,:,:]==1))
            oi = oij/ni
            if ithr==2:
                print('ni',ni)
                print('fi',fi)
                print('oi',oi)
            obs_f[ithr,ibin+1] = oi
            fcst_f[ithr,ibin+1] = fi
    return obs_f, fcst_f

def prob_fcst(fcst,thr,filename=None):
    """ input:
            fcst  = (nmembers,nx,ny)
            thr = thresholds of dBZ
        output: prob_tmp = (nthr,nx,ny) 
    """
    import numpy as np
    import pickle
    nmembers = fcst.shape[0]
    nx = fcst.shape[1]
    ny = fcst.shape[2]
    nthr = len(thr)
    prob_tmp = np.ma.zeros((nthr,nx,ny))
    den = np.zeros((nthr,nx,ny))
    #fcst = np.ma.masked_invalid(fcst)
    for ithr in range(nthr):
        aa = ((fcst>=thr[ithr]))
        bb = np.ma.where(aa==True,1,aa)# 1 is placed where the previous condition is met
        #print(bb.shape)
        prob_tmp[ithr,:,:] = np.ma.sum(bb,axis=0)
        den[ithr,:,:] = bb.count(axis=0)
        #print(bb.count(axis=0))
    prob_tmp = (prob_tmp/den)#*100    
    if filename :
         with open(filename, 'wb') as handle:
            pickle.dump(prob_tmp, handle)
    return prob_tmp # values between 0 and 1


def prob_obs(obs,thr,filename=None):
    """ input:
            obs  = (nx,ny)
            thr = thresholds of dBZ
        output: prob_tmp = (thr,nx,ny) 
    """
    import numpy as np
    import pickle
    nx = obs.shape[0]
    ny = obs.shape[1]
    nthr = len(thr)
    prob_tmp = np.ma.zeros((nthr,nx,ny))
    #obs = np.ma.masked_invalid(obs)
    for ithr in range(nthr):
        aa = ((obs>=thr[ithr]))
        prob = np.ma.where(aa==True,1,aa)
        prob_tmp[ithr,:,:] = prob
        #print(bb.shape)    
    if filename :
         with open(filename, 'wb') as handle:
            pickle.dump(prob_tmp, handle)
    return prob_tmp # values 0 or 1


def rankz(ensemble,obs,mask):
    ''' Parameters
    ----------
    obs : array of observations 
    ensemble : array of ensemble, with the first dimension being the 
        ensemble member and the remaining dimensions being identical to obs
    mask : boolean mask of shape of obs, with zero/false being where grid cells are masked.  
    Returns
    -------
    histogram data for ensemble.shape[0] + 1 bins. 
    The first dimension of this array is the height of 
    each histogram bar, the second dimension is the histogram bins. 
         '''

    mask=np.bool_(mask) #(10,161,161)

    obs=obs[mask] #(259210,) = ordena obs en columna aplicando la mascara
    ensemble=ensemble[:,mask] #(20,259210)

    combined=np.vstack((obs[np.newaxis],ensemble)) #(21,259210)

    # print('computing ranks')
    ranks=np.apply_along_axis(lambda x: rankdata(x,method='min'),0,combined) #(21,259210)

    # print('computing ties')
    ties=np.sum(ranks[0]==ranks[1:], axis=0) #(259210,)
    ranks=ranks[0] #(259210,)
    tie=np.unique(ties) #(21,)

    for i in range(1,len(tie)):
        index=ranks[ties==tie[i]]
        # print('randomizing tied ranks for ' + str(len(index)) + ' instances where there is ' + str(tie[i]) + ' tie/s. ' + str(len(tie)-i-1) + ' more to go')
        ranks[ties==tie[i]]=[np.random.randint(index[j],index[j]+tie[i]+1,tie[i])[0] for j in range(len(index))]

    return np.histogram(ranks, bins=np.linspace(0.5, combined.shape[0]+0.5, combined.shape[0]+1))


