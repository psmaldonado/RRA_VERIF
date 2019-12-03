def do_ets(obs, forecast, umbral):

    import numpy as np

	# obs contiene las observaciones (dbz)
	# forecast contiene los pronosticos, tiene tantas columnas como pronosticos\
	# a verificar. Por ej, primer columna pronostico a 5min, segunda columna \
	#pronostico a 10min.
	# umbral es el vector con los umbrales para los cuales se va a calcular el \
	#ETS.

    n_umb = len(umbral) # Vemos cuantos umbrales distintos tenemos
    a = forecast.shape
    ens = a[1] 
    hits = np.empty((n_umb, ens)) 
    misses = np.empty((n_umb, ens))
    false_alarm = np.empty((n_umb, ens))
    totdbz = np.empty((n_umb, ens))
    misses = np.empty((n_umb, ens))
    hits_random = np.empty((n_umb, ens))
    ets = np.empty((n_umb, ens))
    for i_umb in range(n_umb):
        for iens in range(ens): 
            i_hits = np.nonzero((obs[:, iens] >= umbral[i_umb]) & \
			(forecast[:, iens] >= umbral[i_umb]))
            hits[i_umb, iens] = len(i_hits[0])
            del i_hits
            i_for = np.nonzero((obs[:, iens] >= umbral[i_umb]) & \
			(forecast[:, iens] >= 0))
            totdbz[i_umb, iens] = len(i_for[0])
            misses[i_umb, iens] = totdbz[i_umb, iens]-hits[i_umb, iens]
            del i_for
            i_false = np.nonzero((obs[:, iens] < umbral[i_umb]) & \
			(forecast[:, iens] >= umbral[i_umb])) #Falsas alarmas
            false_alarm[i_umb, iens] = len(i_false[0])
            del i_false

            total = a[0]

            hits_random[i_umb, iens] = (hits[i_umb, iens] + \
			misses[i_umb, iens]) * (hits[i_umb, iens] + \
			false_alarm[i_umb, iens]) / float(total)
            ets[i_umb, iens] = (hits[i_umb, iens] - \
			hits_random[i_umb, iens]) / float((hits[i_umb, iens] + \
			misses[i_umb, iens] + false_alarm[i_umb, iens] - \
			hits_random[i_umb, iens]))

    return ets

def do_ets_new(obs, forecast, umbral):

    import numpy as np

        # obs contiene las observaciones (dbz)
        # forecast contiene los pronosticos
        # umbral es el vector con los umbrales para los cuales se va a calcular el \
        #ETS.

    n_umb = len(umbral) # Vemos cuantos umbrales distintos tenemos
    hits = np.empty(n_umb)
    misses = np.empty(n_umb)
    false_alarm = np.empty(n_umb)
    totdbz = np.empty(n_umb)
    misses = np.empty(n_umb)
    hits_random = np.empty(n_umb)
    ets = np.empty(n_umb)
    for i_umb in range(n_umb):
        i_hits = np.nonzero((obs[:] >= umbral[i_umb]) & \
                        (forecast[:] >= umbral[i_umb]))
        hits[i_umb] = len(i_hits[0])
        del i_hits
        i_for = np.nonzero((obs[:] >= umbral[i_umb]) & \
                        (forecast[:] >= 0))
        totdbz[i_umb] = len(i_for[0])
        misses[i_umb] = totdbz[i_umb]-hits[i_umb]
        del i_for
        i_false = np.nonzero((obs[:] < umbral[i_umb]) & \
                        (forecast[:] >= umbral[i_umb])) #Falsas alarmas
        false_alarm[i_umb] = len(i_false[0])
        del i_false

        total = obs.shape[0]

        hits_random[i_umb] = (hits[i_umb] + \
                        misses[i_umb]) * (hits[i_umb] + \
                        false_alarm[i_umb]) / float(total)
        ets[i_umb] = (hits[i_umb] - \
                        hits_random[i_umb]) / float((hits[i_umb] + \
                        misses[i_umb] + false_alarm[i_umb] - \
                        hits_random[i_umb]))

    return ets
